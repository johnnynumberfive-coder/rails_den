module RailsDen
  class TopicsController < ApplicationController
    def new
      @board = find_public_board
      @topic = @board.topics.build
      @opening_post = Post.new
    end

    def create
      @board = find_public_board
      @topic = @board.topics.build(topic_params)
      @topic.author = current_rails_den_user

      @opening_post = Post.new(opening_post_params)
      @opening_post.topic = @topic
      @opening_post.author = current_rails_den_user

      if @topic.valid? && @opening_post.valid?
        Topic.transaction do
          @topic.save!
          @opening_post.save!
        end

        redirect_to topic_path(@topic)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
      @topic = find_public_topic
      @posts = @topic.posts.order(:created_at, :id)
      @post = @topic.posts.build
    end

    private

    def find_public_board
      board = Board
        .where(enabled: true, visibility: "public")
        .find(params[:board_id])

      unless board.category.enabled? &&
             board.category.visibility_public?
        raise ActiveRecord::RecordNotFound
      end

      board
    end

    def find_public_topic
      topic = Topic.find(params[:id])
      topic
    end

    def topic_params
      params.require(:rails_den_topic).permit(
        :title,
        :slug
      )
    end

    def opening_post_params
      params.require(:rails_den_post).permit(
        :body
      )
    end
  end
end