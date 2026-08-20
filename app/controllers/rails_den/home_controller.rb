module RailsDen
  class HomeController < ApplicationController
    skip_before_action :authenticate_rails_den_user!

    def index
      @categories = Category
        .where(enabled: true, visibility: "public")
        .ordered
    end
  end
end