require "rails/generators"
require "rails_den"

module RailsDen
  module Generators
    module Install
      class ViewsGenerator < Rails::Generators::Base
        source_root RailsDen::Engine.root.join("app/views").to_s

        desc "Copies RailsDen's default views into the host application."

        def copy_views
          copy_file(
            "layouts/rails_den/application.html.erb",
            "app/views/layouts/rails_den/application.html.erb"
          )

          copy_file(
            "rails_den/sessions/new.html.erb",
            "app/views/rails_den/sessions/new.html.erb"
          )

          copy_file(
            "rails_den/registrations/new.html.erb",
            "app/views/rails_den/registrations/new.html.erb"
          )

          copy_file(
            "rails_den/registrations/edit.html.erb",
            "app/views/rails_den/registrations/edit.html.erb"
          )

          copy_file(
            "rails_den/passwords/new.html.erb",
            "app/views/rails_den/passwords/new.html.erb"
          )

          copy_file(
            "rails_den/passwords/edit.html.erb",
            "app/views/rails_den/passwords/edit.html.erb"
          )

          copy_file(
            "rails_den/passwords_mailer/reset.html.erb",
            "app/views/rails_den/passwords_mailer/reset.html.erb"
          )

          copy_file(
            "rails_den/passwords_mailer/reset.text.erb",
            "app/views/rails_den/passwords_mailer/reset.text.erb"
          )
        end
      end
    end
  end
end