module RailsDen
  class ApplicationController < RailsDen.config.parent_controller.constantize
    helper_method :current_rails_den_user,
                  :rails_den_user_signed_in?

    def current_rails_den_user
      public_send(RailsDen.config.current_user_method)
    end

    def rails_den_user_signed_in?
      current_rails_den_user.present?
    end

    def authenticate_rails_den_user!
      return if rails_den_user_signed_in?

      public_send(RailsDen.config.authentication_method)
    end
  end
end
