module RailsDen
  class Configuration
    attr_accessor :user_class,
                  :current_user_method,
                  :authentication_method,
                  :parent_controller

    def initialize
      @user_class = "User"
      @current_user_method = :current_user
      @authentication_method = :authenticate_user!
      @parent_controller = "ApplicationController"
    end
  end
end