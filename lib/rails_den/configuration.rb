module RailsDen
  class Configuration
    attr_accessor :user_class,
                  :current_user_method,
                  :current_user_resolver,
                  :authentication_method,
                  :authentication_handler,
                  :parent_controller,
                  :registration_enabled

    def initialize
      @user_class = "User"
      @current_user_method = :current_user
      @current_user_resolver = nil
      @authentication_method = :authenticate_user!
      @authentication_handler = nil
      @parent_controller = "ApplicationController"
      @registration_enabled = true
    end
  end
end