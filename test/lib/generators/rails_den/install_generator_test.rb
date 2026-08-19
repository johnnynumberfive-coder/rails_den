require "test_helper"
require "rails/generators"
require "rails/generators/test_case"
require "generators/rails_den/install/install_generator"

module RailsDen
  module Generators
    class InstallGeneratorTest < Rails::Generators::TestCase
      tests RailsDen::Generators::InstallGenerator

      destination File.expand_path("../../../../tmp/install_generator", __dir__)

      setup do
        prepare_destination
      end

      test "creates the RailsDen initializer" do
        run_generator

        assert_file "config/initializers/rails_den.rb" do |initializer|
          assert_match 'config.user_class = "User"', initializer
          assert_match "config.current_user_method = :current_user", initializer
          assert_match "config.authentication_method = :authenticate_user!", initializer
          assert_match 'config.parent_controller = "ApplicationController"', initializer
        end
      end
    end
  end
end