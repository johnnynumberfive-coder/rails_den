require "test_helper"

class RailsDenAdminBoardsTest < ActionDispatch::IntegrationTest
  test "anonymous visitor is sent to login" do
    get "/rails_den/admin/boards"

    assert_redirected_to "/session/new"
  end

  test "ordinary member cannot access boards administration" do
    user = create_user
    sign_in(user)

    get "/rails_den/admin/boards"

    assert_response :forbidden
  end

  test "RailsDen administrator can access boards administration" do
    user = create_user

    RailsDen::Administrator.create!(
      user: user
    )

    category = RailsDen::Category.create!(
      title: "General",
      slug: "general"
    )

    RailsDen::Board.create!(
      category: category,
      title: "Announcements",
      slug: "announcements"
    )

    sign_in(user)

    get "/rails_den/admin/boards"

    assert_response :success
    assert_includes response.body, "Boards"
    assert_includes response.body, "Announcements"
    assert_includes response.body, "General"
  end

  private

  def create_user
    User.create!(
      email_address: "member@example.com",
      password: "password123",
      password_confirmation: "password123"
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