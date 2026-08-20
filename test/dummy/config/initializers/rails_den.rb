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