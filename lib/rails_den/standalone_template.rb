rails_den_spec = Gem.loaded_specs["rails_den"]
rails_den_source = rails_den_spec&.full_gem_path

if rails_den_source && File.exist?(File.join(rails_den_source, ".git"))
  gem "rails_den", path: rails_den_source
else
  gem "rails_den", "~> #{RailsDen::VERSION}"
end


after_bundle do
  generate "authentication"
  generate "simple_form:install"

  remove_file "app/models/user.rb"

  file "app/models/user.rb", <<~RUBY
    class User < ApplicationRecord
      has_secure_password
      has_many :sessions, dependent: :destroy

      attr_accessor :current_password

      normalizes :email_address, with: ->(e) { e.strip.downcase }
    end
  RUBY

  file "app/controllers/rails_den_controller.rb", <<~RUBY
    class RailsDenController < ApplicationController
      allow_unauthenticated_access
    end
  RUBY

  remove_file "app/controllers/sessions_controller.rb"

  file "app/controllers/sessions_controller.rb", <<~RUBY
    class SessionsController < ApplicationController
      allow_unauthenticated_access only: %i[new create]

      rate_limit to: 10,
                 within: 3.minutes,
                 only: :create,
                 with: -> {
                   redirect_to new_session_path,
                               alert: "Try again later."
                 }

      layout "rails_den/application"

      def new
        render "rails_den/sessions/new"
      end

      def create
        credentials = params.expect(
          session: [
            :email_address,
            :password
          ]
        )

        if user = User.authenticate_by(credentials)
          start_new_session_for(user)
          redirect_to after_authentication_url
        else
          redirect_to new_session_path,
                      alert: "Try another email address or password."
        end
      end

      def destroy
        terminate_session
        redirect_to new_session_path, status: :see_other
      end
    end
  RUBY

  file "app/controllers/registrations_controller.rb", <<~RUBY
    class RegistrationsController < ApplicationController
      allow_unauthenticated_access only: %i[new create]

      before_action :ensure_registration_enabled, only: %i[new create]

      layout "rails_den/application"

      def new
        @user = User.new

        render "rails_den/registrations/new"
      end

      def create
        @user = User.new(registration_params)

        if save_registration
          start_new_session_for(@user)
          redirect_to "/rails_den"
        else
          render "rails_den/registrations/new",
                 status: :unprocessable_entity
        end
      end

      def edit
        @user = Current.user

        render "rails_den/registrations/edit"
      end

      def update
        @user = Current.user
        @user.current_password = params.dig(:user, :current_password)

        unless @user.authenticate(@user.current_password.to_s)
          @user.errors.add(:base, "Current password is incorrect.")

          return render "rails_den/registrations/edit",
                        status: :unprocessable_entity
        end

        attributes = account_params.to_h.symbolize_keys

        if attributes[:password].blank?
          attributes.delete(:password)
          attributes.delete(:password_confirmation)
        end

        if @user.update(attributes)
          destroy_other_sessions if attributes.key?(:password)

          redirect_to edit_registration_path,
                      notice: "Your account has been updated."
        else
          render "rails_den/registrations/edit",
                 status: :unprocessable_entity
        end
      end

      private

      def save_registration
        User.transaction do
          next false unless @user.save

          if User.count == 1
            RailsDen::Administrator.create!(
              user: @user
            )
          end

          true
        end
      end

      def registration_params
        params.require(:user).permit(
          :email_address,
          :password,
          :password_confirmation
        )
      end

      def account_params
        params.require(:user).permit(
          :email_address,
          :password,
          :password_confirmation
        )
      end

      def destroy_other_sessions
        @user.sessions.where.not(id: Current.session.id).destroy_all
      end

      def ensure_registration_enabled
        head :not_found unless RailsDen.config.registration_enabled
      end
    end
  RUBY

  remove_file "app/controllers/passwords_controller.rb"

  file "app/controllers/passwords_controller.rb", <<~RUBY
    class PasswordsController < ApplicationController
      allow_unauthenticated_access

      before_action :set_user_by_token,
                    only: %i[edit update]

      rate_limit to: 10,
                 within: 3.minutes,
                 only: :create,
                 with: -> {
                   redirect_to new_password_path,
                               alert: "Try again later."
                 }

      layout "rails_den/application"

      def new
        render "rails_den/passwords/new"
      end

      def create
        email_address = password_reset_params[:email_address]

        if user = User.find_by(email_address: email_address)
          PasswordsMailer.reset(user).deliver_later
        end

        redirect_to new_session_path,
                    notice: "Password reset instructions sent (if user with that email address exists)."
      end

      def edit
        render "rails_den/passwords/edit"
      end

      def update
        if @user.update(password_params)
          @user.sessions.destroy_all

          redirect_to new_session_path,
                      notice: "Password has been reset."
        else
          redirect_to edit_password_path(params[:token]),
                      alert: "Passwords did not match."
        end
      end

      private

      def password_reset_params
        params.require(:password_reset).permit(:email_address)
      end

      def password_params
        params.require(:password).permit(
          :password,
          :password_confirmation
        )
      end

      def set_user_by_token
        @user = User.find_by_password_reset_token!(params[:token])
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        redirect_to new_password_path,
                    alert: "Password reset link is invalid or has expired."
      end
    end
  RUBY

  remove_file "app/mailers/passwords_mailer.rb"

  file "app/mailers/passwords_mailer.rb", <<~RUBY
    class PasswordsMailer < ApplicationMailer
      def reset(user)
        @user = user

        mail(
          subject: "Reset your password",
          to: user.email_address,
          template_path: "rails_den/passwords_mailer",
          template_name: "reset"
        )
      end
    end
  RUBY

  remove_file "app/views/sessions/new.html.erb"
  remove_file "app/views/passwords/new.html.erb"
  remove_file "app/views/passwords/edit.html.erb"
  remove_file "app/views/passwords_mailer/reset.html.erb"
  remove_file "app/views/passwords_mailer/reset.text.erb"

  route <<~RUBY
    root to: redirect("/rails_den")

    resource :registration, only: %i[new create edit update]

    mount RailsDen::Engine => "/rails_den"
  RUBY

  initializer "rails_den.rb", <<~RUBY
    RailsDen.configure do |config|
      config.user_class = "User"

      config.current_user_resolver = -> {
        if respond_to?(:authenticated?, true)
          authenticated? ? Current.user : nil
        elsif (session_id = cookies.signed[:session_id])
          Session.find_by(id: session_id)&.user
        end
      }

      config.authentication_handler = -> {
        session[:return_to_after_authenticating] = request.url
        redirect_to main_app.new_session_path
      }

      config.parent_controller = "RailsDenController"
    end
  RUBY

  rails_command "rails_den:install:migrations"
  rails_command "db:migrate"

  say
  say "============================================================"
  say
  say "RailsDen is ready!"
  say
  say
  say "RailsDen's authentication views are built in and already active."
  say "You do NOT need to install them unless you want to customize them."
  say
  say "To copy the RailsDen views into this application, run:"
  say
  say "    rails_den install:views"
  say
  say "The copied files will appear under app/views and override"
  say "RailsDen's packaged defaults."
  say
  say "============================================================"
  say
end