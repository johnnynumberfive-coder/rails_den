module RailsDen
  class BoardsController < ApplicationController
    skip_before_action :authenticate_rails_den_user!

    def show
      @board = Board
        .where(enabled: true, visibility: "public")
        .find(params[:id])

      unless @board.category.enabled? &&
             @board.category.visibility_public?
        raise ActiveRecord::RecordNotFound
      end
    end
  end
end