module RailsDen
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Installs RailsDen into an existing Rails application"

      def copy_initializer
        template "rails_den.rb", "config/initializers/rails_den.rb"
      end
    end
  end
end