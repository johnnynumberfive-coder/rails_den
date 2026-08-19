module RailsDen
  class ApplicationController < RailsDen.config.parent_controller.constantize
    prepend_before_action :authenticate_rails_den_user!

    helper_method :current_rails_den_user,
                  :rails_den_user_signed_in?

    def current_rails_den_user
      if RailsDen.config.current_user_resolver
        instance_exec(&RailsDen.config.current_user_resolver)
      else
        send(RailsDen.config.current_user_method)
      end
    end

    def rails_den_user_signed_in?
      current_rails_den_user.present?
    end

    def authenticate_rails_den_user!
      return if rails_den_user_signed_in?

      if RailsDen.config.authentication_handler
        instance_exec(&RailsDen.config.authentication_handler)
      else
        send(RailsDen.config.authentication_method)
      end
    end
  end
end