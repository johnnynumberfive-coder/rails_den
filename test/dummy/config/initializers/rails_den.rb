RailsDen.configure do |config|
  config.user_class = "User"

  config.current_user_resolver = -> {
    authenticated? ? Current.user : nil
  }

  config.authentication_handler = -> {
    session[:return_to_after_authenticating] = request.url
    redirect_to main_app.new_session_path
  }

  config.parent_authentication_callback = :require_authentication

  config.parent_controller = "ApplicationController"
end