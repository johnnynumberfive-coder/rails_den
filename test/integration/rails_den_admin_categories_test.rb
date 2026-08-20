require "test_helper"

class RailsDenAdminCategoriesTest < ActionDispatch::IntegrationTest
  test "anonymous visitor is sent to login" do
    get "/rails_den/admin/categories"

    assert_redirected_to "/session/new"
  end

  test "ordinary member cannot access categories administration" do
    user = create_user
    sign_in(user)

    get "/rails_den/admin/categories"

    assert_response :forbidden
  end

  test "RailsDen administrator can access categories administration" do
    user = create_user

    RailsDen::Administrator.create!(
      user: user
    )

    RailsDen::Category.create!(
      title: "General",
      slug: "general"
    )

    sign_in(user)

    get "/rails_den/admin/categories"

    assert_response :success
    assert_includes response.body, "Categories"
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