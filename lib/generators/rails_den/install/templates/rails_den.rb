RailsDen.configure do |config|
  # The host application's user model.
  config.user_class = "User"

  # Method available to controllers that returns the signed-in user.
  config.current_user_method = :current_user

  # Method RailsDen should call when authentication is required.
  config.authentication_method = :authenticate_user!

  # Controller RailsDen controllers inherit from.
  config.parent_controller = "ApplicationController"
end