require "test_helper"

class ConfigurationTest < ActiveSupport::TestCase
  setup do
    RailsDen.reset_configuration!
  end

  teardown do
    RailsDen.reset_configuration!
  end

  test "defaults to User as the host user class" do
    assert_equal "User", RailsDen.config.user_class
  end

  test "defaults to current_user as the host current user method" do
    assert_equal :current_user, RailsDen.config.current_user_method
  end

  test "defaults to authenticate_user! as the host authentication method" do
    assert_equal :authenticate_user!, RailsDen.config.authentication_method
  end

  test "defaults to ApplicationController as the parent controller" do
    assert_equal "ApplicationController", RailsDen.config.parent_controller
  end

  test "allows the host application to configure authentication integration" do
    RailsDen.configure do |config|
      config.user_class = "Account"
      config.current_user_method = :signed_in_account
      config.authentication_method = :require_account!
      config.parent_controller = "AuthenticatedController"
    end

    assert_equal "Account", RailsDen.config.user_class
    assert_equal :signed_in_account, RailsDen.config.current_user_method
    assert_equal :require_account!, RailsDen.config.authentication_method
    assert_equal "AuthenticatedController", RailsDen.config.parent_controller
  end
end