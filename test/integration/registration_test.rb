require "test_helper"

class RegistrationTest < ActionDispatch::IntegrationTest
  setup do
    @original_registration_enabled = RailsDen.config.registration_enabled
  end

  teardown do
    RailsDen.config.registration_enabled = @original_registration_enabled
  end

  test "registration page is available without authentication" do
    get "/registration/new"

    assert_response :success
  end

  test "visitor can create an account and enter RailsDen authenticated" do
    assert_difference "User.count", 1 do
      post "/registration", params: {
        user: {
          email_address: "newmember@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_redirected_to "/rails_den"

    follow_redirect!

    assert_response :success
    assert_includes response.body, "Welcome to RailsDen"
    assert_includes response.body, "newmember@example.com"
  end

  test "invalid registration is rejected" do
    assert_no_difference "User.count" do
      post "/registration", params: {
        user: {
          email_address: "invalid@example.com",
          password: "password123",
          password_confirmation: "different-password"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "registration page is unavailable when registration is disabled" do
    RailsDen.config.registration_enabled = false

    get "/registration/new"

    assert_response :not_found
  end

  test "account cannot be created when registration is disabled" do
    RailsDen.config.registration_enabled = false

    assert_no_difference "User.count" do
      post "/registration", params: {
        user: {
          email_address: "blocked@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_response :not_found
  end

  test "account settings require authentication" do
    get "/registration/edit"

    assert_redirected_to "/session/new"
  end

  test "authenticated user can view account settings" do
    user = create_user
    sign_in(user)

    get "/registration/edit"

    assert_response :success
    assert_includes response.body, "Account settings"
  end

  test "authenticated user can change email address" do
    user = create_user
    sign_in(user)

    patch "/registration", params: {
      user: {
        email_address: "changed@example.com",
        password: "",
        password_confirmation: "",
        current_password: "password123"
      }
    }

    assert_redirected_to "/registration/edit"
    assert_equal "changed@example.com", user.reload.email_address
  end

  test "authenticated user can change password" do
    user = create_user
    sign_in(user)

    patch "/registration", params: {
      user: {
        email_address: user.email_address,
        password: "newpassword123",
        password_confirmation: "newpassword123",
        current_password: "password123"
      }
    }

    assert_redirected_to "/registration/edit"

    user.reload

    assert user.authenticate("newpassword123")
    assert_not user.authenticate("password123")
  end

  test "current password is required to update account" do
    user = create_user
    sign_in(user)

    patch "/registration", params: {
      user: {
        email_address: "hacker@example.com",
        password: "",
        password_confirmation: "",
        current_password: "wrong-password"
      }
    }

    assert_response :unprocessable_entity
    assert_equal "member@example.com", user.reload.email_address
    assert_includes response.body, "Current password is incorrect"
  end

  test "disabling registration does not disable account settings" do
    user = create_user
    sign_in(user)

    RailsDen.config.registration_enabled = false

    get "/registration/edit"

    assert_response :success
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