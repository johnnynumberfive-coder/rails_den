require "test_helper"

class RailsDenAuthenticationTest < ActionDispatch::IntegrationTest
  test "unauthenticated user is sent to host login" do
    get "/rails_den/auth_probe"

    assert_redirected_to "/session/new"
  end

  test "authenticated host user is available inside RailsDen" do
    user = User.create!(
      email_address: "member@example.com",
      password: "password123"
    )

    get "/rails_den/auth_probe"

    assert_redirected_to "/session/new"

    post "/session", params: {
      session: {
        email_address: user.email_address,
        password: "password123"
      }
    }

    assert_response :redirect

    follow_redirect!

    assert_response :success
    assert_equal user.email_address, response.body
  end
end