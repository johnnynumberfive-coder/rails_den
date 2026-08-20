require "test_helper"
require "generators/rails_den/install/views/views_generator"

class RailsDenInstallViewsGeneratorTest < Rails::Generators::TestCase
  tests RailsDen::Generators::Install::ViewsGenerator

  destination Rails.root.join("tmp/rails_den_install_views")

  setup :prepare_destination

  test "copies RailsDen auth views into the host application" do
    run_generator

    assert_file "app/views/layouts/rails_den/application.html.erb"

    assert_file "app/views/rails_den/sessions/new.html.erb"

    assert_file "app/views/rails_den/registrations/new.html.erb"
    assert_file "app/views/rails_den/registrations/edit.html.erb"

    assert_file "app/views/rails_den/passwords/new.html.erb"
    assert_file "app/views/rails_den/passwords/edit.html.erb"

    assert_file "app/views/rails_den/passwords_mailer/reset.html.erb"
    assert_file "app/views/rails_den/passwords_mailer/reset.text.erb"
  end
end