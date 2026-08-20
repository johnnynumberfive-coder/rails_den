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

    if @user.save
      start_new_session_for(@user)
      redirect_to "/rails_den/auth_probe"
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
