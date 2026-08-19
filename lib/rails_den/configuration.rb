module RailsDen
  class Configuration
    attr_accessor :user_class,
                  :current_user_method,
                  :current_user_resolver,
                  :authentication_method,
                  :authentication_handler,
                  :parent_authentication_callback,
                  :parent_controller

    def initialize
      @user_class = "User"
      @current_user_method = :current_user
      @current_user_resolver = nil
      @authentication_method = :authenticate_user!
      @authentication_handler = nil
      @parent_authentication_callback = nil
      @parent_controller = "ApplicationController"
    end
  end
end