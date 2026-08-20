class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  rate_limit to: 10,
             within: 3.minutes,
             only: :create,
             with: -> {
               redirect_to new_session_path,
                           alert: "Try again later."
             }

  layout "rails_den/application"

  def new
    render "rails_den/sessions/new"
  end

  def create
    credentials = params.expect(
      session: [
        :email_address,
        :password
      ]
    )

    if user = User.authenticate_by(credentials)
      start_new_session_for(user)
      redirect_to after_authentication_url
    else
      redirect_to new_session_path,
                  alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
