module Admin
  module RailsDen
    class ApplicationController < ::Administrate::ApplicationController
      helper ::RailsDen::Engine.routes.url_helpers

      before_action :require_rails_den_administrator!

      helper_method :current_rails_den_user,
                    :rails_den_administrator?

      private

      def routes
        @routes ||= ::RailsDen::Engine.routes.routes.filter_map do |route|
          controller = route.defaults[:controller]
          next unless controller&.start_with?("#{namespace}/")

          [
            controller.delete_prefix("#{namespace}/"),
            route.defaults[:action]
          ]
        end.to_set
      end

      def current_rails_den_user
        return @current_rails_den_user if defined?(@current_rails_den_user)

        @current_rails_den_user =
          if ::RailsDen.config.current_user_resolver
            instance_exec(&::RailsDen.config.current_user_resolver)
          elsif respond_to?(::RailsDen.config.current_user_method, true)
            send(::RailsDen.config.current_user_method)
          end
      end

      def rails_den_administrator?
        current_rails_den_user.present? &&
          ::RailsDen::Administrator.exists?(
            user: current_rails_den_user
          )
      end

      def require_rails_den_administrator!
        unless current_rails_den_user
          if ::RailsDen.config.authentication_handler
            return instance_exec(
              &::RailsDen.config.authentication_handler
            )
          end

          return head :unauthorized
        end

        head :forbidden unless rails_den_administrator?
      end
    end
  end
end