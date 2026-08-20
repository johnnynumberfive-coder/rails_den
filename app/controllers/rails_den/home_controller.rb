module RailsDen
  class HomeController < ApplicationController
    skip_before_action :authenticate_rails_den_user!

    def index
    end
  end
end