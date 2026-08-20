require "test_helper"

module RailsDen
  class ApplicationControllerTest < ActiveSupport::TestCase
    setup do
      @original_configuration = RailsDen.configuration
      RailsDen.reset_configuration!
    end

    teardown do
      RailsDen.instance_variable_set(
        :@configuration,
        @original_configuration
      )
    end

    test "returns the user from the configured current user method" do
      user = Object.new
      controller = RailsDen::ApplicationController.new

      controller.define_singleton_method(:current_user) do
        user
      end

      assert_same user, controller.current_rails_den_user
    end

    test "supports a custom current user method" do
      user = Object.new

      RailsDen.configure do |config|
        config.current_user_method = :signed_in_account
      end

      controller = RailsDen::ApplicationController.new

      controller.define_singleton_method(:signed_in_account) do
        user
      end

      assert_same user, controller.current_rails_den_user
    end

    test "uses the configured current user resolver when present" do
      user = Object.new

      RailsDen.configure do |config|
        config.current_user_resolver = -> { user }
      end

      controller = RailsDen::ApplicationController.new

      assert_same user, controller.current_rails_den_user
    end

    test "current user resolver takes precedence over current user method" do
      resolved_user = Object.new
      method_user = Object.new

      RailsDen.configure do |config|
        config.current_user_resolver = -> { resolved_user }
      end

      controller = RailsDen::ApplicationController.new

      controller.define_singleton_method(:current_user) do
        method_user
      end

      assert_same resolved_user, controller.current_rails_den_user
    end

    test "reports when a RailsDen user is signed in" do
      user = Object.new
      controller = RailsDen::ApplicationController.new

      controller.define_singleton_method(:current_user) do
        user
      end

      assert controller.rails_den_user_signed_in?
    end

    test "reports when no RailsDen user is signed in" do
      controller = RailsDen::ApplicationController.new

      controller.define_singleton_method(:current_user) do
        nil
      end

      assert_not controller.rails_den_user_signed_in?
    end

    test "does not authenticate when already signed in" do
      user = Object.new
      authentication_called = false
      controller = RailsDen::ApplicationController.new

      controller.define_singleton_method(:current_user) do
        user
      end

      controller.define_singleton_method(:authenticate_user!) do
        authentication_called = true
      end

      controller.authenticate_rails_den_user!

      assert_not authentication_called
    end

    test "calls the configured authentication method when signed out" do
      authentication_called = false

      RailsDen.configure do |config|
        config.authentication_method = :require_account!
      end

      controller = RailsDen::ApplicationController.new

      controller.define_singleton_method(:current_user) do
        nil
      end

      controller.define_singleton_method(:require_account!) do
        authentication_called = true
      end

      controller.authenticate_rails_den_user!

      assert authentication_called
    end

    test "can call a private authentication method" do
      authentication_called = false

      RailsDen.configure do |config|
        config.authentication_method = :require_authentication
      end

      controller = RailsDen::ApplicationController.new

      controller.define_singleton_method(:current_user) do
        nil
      end

      controller.define_singleton_method(:require_authentication) do
        authentication_called = true
      end

      controller.singleton_class.send(
        :private,
        :require_authentication
      )

      controller.authenticate_rails_den_user!

      assert authentication_called
    end

    test "uses the configured authentication handler when present" do
      authentication_called = false

      RailsDen.configure do |config|
        config.authentication_handler = -> {
          authentication_called = true
        }
      end

      controller = RailsDen::ApplicationController.new

      controller.define_singleton_method(:current_user) do
        nil
      end

      controller.authenticate_rails_den_user!

      assert authentication_called
    end
  end
end