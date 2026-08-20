require "fileutils"

module RailsDen
  class ViewInstaller
    VIEW_FILES = [
      "layouts/rails_den/application.html.erb",
      "layouts/rails_den/_navbar.html.erb",
      "rails_den/sessions/new.html.erb",
      "rails_den/registrations/new.html.erb",
      "rails_den/registrations/edit.html.erb",
      "rails_den/passwords/new.html.erb",
      "rails_den/passwords/edit.html.erb",
      "rails_den/passwords_mailer/reset.html.erb",
      "rails_den/passwords_mailer/reset.text.erb"
    ].freeze

    def initialize(
      destination_root: Dir.pwd,
      source_root: File.expand_path("../../app/views", __dir__),
      out: $stdout
    )
      @destination_root = File.expand_path(destination_root)
      @source_root = File.expand_path(source_root)
      @out = out
    end

    def install(force: false)
      ensure_rails_application!

      VIEW_FILES.each do |relative_path|
        copy_view(relative_path, force: force)
      end
    end

    private

    def ensure_rails_application!
      application_file = File.join(
        @destination_root,
        "config",
        "application.rb"
      )

      return if File.file?(application_file)

      raise ArgumentError,
            "rails_den install:views must be run from a Rails application root"
    end

    def copy_view(relative_path, force:)
      source = File.join(@source_root, relative_path)
      destination = File.join(
        @destination_root,
        "app",
        "views",
        relative_path
      )

      unless File.file?(source)
        raise Errno::ENOENT, "RailsDen view not found: #{source}"
      end

      if File.exist?(destination) && !force
        @out.puts "      exists  #{display_path(destination)}"
        return
      end

      FileUtils.mkdir_p(File.dirname(destination))
      FileUtils.cp(source, destination)

      action = force ? "       force" : "      create"

      @out.puts "#{action}  #{display_path(destination)}"
    end

    def display_path(path)
      path.delete_prefix("#{@destination_root}/")
    end
  end
end