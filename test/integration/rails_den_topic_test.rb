require "test_helper"

class RailsDenTopicsTest < ActionDispatch::IntegrationTest
  test "anonymous visitor is sent to login when starting a topic" do
    board = create_board

    get "/rails_den/boards/#{board.id}/topics/new"

    assert_redirected_to "/session/new"
  end

  test "authenticated member can view new topic form" do
    user = create_user
    board = create_board

    sign_in(user)

    get "/rails_den/boards/#{board.id}/topics/new"

    assert_response :success
    assert_includes response.body, "Start a new topic"
    assert_includes response.body, board.title
  end

  test "authenticated member can create a topic" do
    user = create_user
    board = create_board

    sign_in(user)

    assert_difference "RailsDen::Topic.count", 1 do
      post "/rails_den/boards/#{board.id}/topics", params: {
        rails_den_topic: {
          title: "Welcome to RailsDen",
          slug: "welcome-to-railsden"
        }
      }
    end

    topic = RailsDen::Topic.order(:id).last

    assert_redirected_to "/rails_den/boards/#{board.id}"

    assert_equal board, topic.board
    assert_equal user, topic.author
    assert_equal "Welcome to RailsDen", topic.title
    assert_equal "welcome-to-railsden", topic.slug
  end

  test "invalid topic is rejected" do
    user = create_user
    board = create_board

    sign_in(user)

    assert_no_difference "RailsDen::Topic.count" do
      post "/rails_den/boards/#{board.id}/topics", params: {
        rails_den_topic: {
          title: "",
          slug: "invalid topic"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_includes response.body, "We couldn't create this topic"
  end

  test "topic author cannot be supplied through params" do
    user = create_user
    other_user = User.create!(
      email_address: "other@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    board = create_board

    sign_in(user)

    post "/rails_den/boards/#{board.id}/topics", params: {
      rails_den_topic: {
        title: "Secure Author Test",
        slug: "secure-author-test",
        author_id: other_user.id,
        author_type: "User"
      }
    }

    topic = RailsDen::Topic.order(:id).last

    assert_equal user, topic.author
    assert_not_equal other_user, topic.author
  end

  test "disabled board cannot be used to start a topic" do
    user = create_user

    board = create_board(
      enabled: false
    )

    sign_in(user)

    get "/rails_den/boards/#{board.id}/topics/new"

    assert_response :not_found
  end

  test "private board cannot be used to start a topic" do
    user = create_user

    board = create_board(
      visibility: "private"
    )

    sign_in(user)

    get "/rails_den/boards/#{board.id}/topics/new"

    assert_response :not_found
  end

  test "topic cannot be started when board category is disabled" do
    user = create_user

    category = RailsDen::Category.create!(
      title: "Hidden",
      slug: "hidden",
      enabled: false
    )

    board = RailsDen::Board.create!(
      category: category,
      title: "Announcements",
      slug: "announcements"
    )

    sign_in(user)

    get "/rails_den/boards/#{board.id}/topics/new"

    assert_response :not_found
  end

  test "topic cannot be started when board category is private" do
    user = create_user

    category = RailsDen::Category.create!(
      title: "Private",
      slug: "private",
      visibility: "private"
    )

    board = RailsDen::Board.create!(
      category: category,
      title: "Announcements",
      slug: "announcements"
    )

    sign_in(user)

    get "/rails_den/boards/#{board.id}/topics/new"

    assert_response :not_found
  end

  private

  def create_user
    User.create!(
      email_address: "member@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  def create_board(enabled: true, visibility: "public")
    category = RailsDen::Category.create!(
      title: "General",
      slug: "general"
    )

    RailsDen::Board.create!(
      category: category,
      title: "Announcements",
      slug: "announcements",
      enabled: enabled,
      visibility: visibility
    )
  end

  def sign_in(user)
    post "/session", params: {
      session: {
        email_address: user.email_address,
        password: "password123"
      }
    }

    assert_response :redirect
  end
end