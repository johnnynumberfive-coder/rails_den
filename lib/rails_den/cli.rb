require "bundler"
require "rails_den/version"
require "rails_den/view_installer"
require "rails/generators"
require "rails/generators/rails/app/app_generator"

module RailsDen
  class CLI
    DEFAULT_TEMPLATE_PATH = File.expand_path(
      "standalone_template.rb",
      __dir__
    )

    def self.start(
      argv,
      out: $stdout,
      err: $stderr,
      app_generator: Rails::Generators::AppGenerator,
      view_installer_class: RailsDen::ViewInstaller,
      template_path: DEFAULT_TEMPLATE_PATH
    )
      new(
        argv,
        out: out,
        err: err,
        app_generator: app_generator,
        view_installer_class: view_installer_class,
        template_path: template_path
      ).start
    end

    def initialize(
      argv,
      out:,
      err:,
      app_generator:,
      view_installer_class:,
      template_path:
    )
      @argv = argv.dup
      @out = out
      @err = err
      @app_generator = app_generator
      @view_installer_class = view_installer_class
      @template_path = template_path
    end

    def start
      command = @argv.shift

      case command
      when nil, "-h", "--help", "help"
        print_help
        0
      when "-v", "--version", "version"
        @out.puts RailsDen::VERSION
        0
      when "new"
        create_application
      when "install:views"
        install_views
      else
        @err.puts "Unknown command: #{command}"
        @err.puts
        print_help(@err)
        1
      end
    rescue ArgumentError => error
      @err.puts error.message
      1
    end

    private

    def create_application
      name = @argv.shift

      if name.nil? || name.strip.empty?
        @err.puts "Usage: rails_den new NAME [rails options]"
        return 1
      end

      Bundler.with_unbundled_env do
        @app_generator.start(
          [
            name,
            *@argv,
            "--template=#{@template_path}"
          ]
        )
      end

      0
    end

    def install_views
      force = false

      @argv.each do |argument|
        case argument
        when "--force"
          force = true
        else
          @err.puts "Unknown option for install:views: #{argument}"
          @err.puts
          @err.puts "Usage: rails_den install:views [--force]"
          return 1
        end
      end

      installer = @view_installer_class.new(
        destination_root: Dir.pwd,
        out: @out
      )

      installer.install(force: force)

      @out.puts
      @out.puts "RailsDen views are now available under app/views."
      @out.puts "Your local copies override RailsDen's packaged defaults."

      0
    end

    def print_help(io = @out)
      io.puts <<~HELP
        RailsDen #{RailsDen::VERSION}

        Usage:
          rails_den new NAME [rails options]
          rails_den install:views [--force]
          rails_den --version
          rails_den --help

        Commands:
          new NAME
              Create a new standalone RailsDen application.

          install:views
              Copy RailsDen's packaged views into the current Rails app
              so they can be customized.

              Existing files are preserved by default.
              Use --force to replace them with RailsDen's defaults.

        Examples:
          rails_den new community
          rails_den new community --database=postgresql

          cd community
          rails_den install:views
          rails_den install:views --force
      HELP
    end
  end
end