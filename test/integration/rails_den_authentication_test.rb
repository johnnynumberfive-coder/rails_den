require "test_helper"

class RailsDenAuthenticationTest < ActionDispatch::IntegrationTest
  test "RailsDen home is available without authentication" do
    get "/rails_den"

    assert_response :success
    assert_includes response.body, "Welcome to RailsDen"
    assert_includes response.body, "Sign in"
  end

  test "authenticated host user is available inside RailsDen" do
    user = User.create!(
      email_address: "member@example.com",
      password: "password123"
    )

    post "/session", params: {
      session: {
        email_address: user.email_address,
        password: "password123"
      }
    }

    assert_response :redirect

    get "/rails_den"

    assert_response :success
    assert_includes response.body, user.email_address
    assert_includes response.body, "Account"
    assert_includes response.body, "Sign out"
  end
end