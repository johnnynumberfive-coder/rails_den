module RailsDen
  class AuthProbeController < ApplicationController
    def show
      render plain: current_rails_den_user.email_address
    end
  end
end