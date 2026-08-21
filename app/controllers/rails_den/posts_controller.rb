module RailsDen
  class PostsController < ApplicationController
    def create
      @topic = find_public_topic
      @post = @topic.posts.build(post_params)
      @post.author = current_rails_den_user

      if @post.save
        redirect_to topic_path(@topic)
      else
        @posts = @topic.posts.where.not(id: nil).order(:created_at, :id)
        render "rails_den/topics/show",
               status: :unprocessable_entity
      end
    end

    private

    def find_public_topic
      topic = Topic.find(params[:topic_id])

      board = topic.board

      unless board.enabled? &&
             board.visibility_public? &&
             board.category.enabled? &&
             board.category.visibility_public?
        raise ActiveRecord::RecordNotFound
      end

      topic
    end

    def post_params
      params.require(:rails_den_post).permit(
        :body
      )
    end
  end
end