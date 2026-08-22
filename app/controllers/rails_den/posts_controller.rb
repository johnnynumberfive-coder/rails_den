module RailsDen
  class PostsController < ApplicationController
    before_action :find_post, only: %i[edit update]
    before_action :require_post_owner!, only: %i[edit update]

    def create
      @topic = find_public_topic

      return head :forbidden if @topic.locked?

      @post = @topic.posts.build(post_params)
      @post.author = current_rails_den_user

      if @post.save
        redirect_to topic_path(@topic)
      else
        @posts = @topic.posts
          .where.not(id: nil)
          .order(:created_at, :id)

        render "rails_den/topics/show",
               status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @post.update(post_params)
        redirect_to topic_path(@topic)
      else
        render :edit,
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

    def find_post
      @topic = find_public_topic
      @post = @topic.posts.find(params[:id])
    end

    def require_post_owner!
      return if @post.author == current_rails_den_user

      head :forbidden
    end

    def post_params
      params.require(:rails_den_post).permit(
        :body
      )
    end
  end
end