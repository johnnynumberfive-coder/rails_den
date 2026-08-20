require "rails_den/version"
require "rails/generators"
require "rails/generators/rails/app/app_generator"

module RailsDen
  class CLI
    def self.start(
      argv,
      out: $stdout,
      err: $stderr,
      app_generator: Rails::Generators::AppGenerator
    )
      new(
        argv,
        out: out,
        err: err,
        app_generator: app_generator
      ).start
    end

    def initialize(argv, out:, err:, app_generator:)
      @argv = argv.dup
      @out = out
      @err = err
      @app_generator = app_generator
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
      else
        @err.puts "Unknown command: #{command}"
        @err.puts
        print_help(@err)
        1
      end
    end

    private

    def create_application
      name = @argv.shift

      if name.nil? || name.strip.empty?
        @err.puts "Usage: rails_den new NAME [rails options]"
        return 1
      end

      @app_generator.start([name, *@argv])
      0
    end

    def print_help(io = @out)
      io.puts <<~HELP
        RailsDen #{RailsDen::VERSION}

        Usage:
          rails_den new NAME [rails options]
          rails_den --version
          rails_den --help

        Commands:
          new NAME    Create a new standalone RailsDen application

        Examples:
          rails_den new community
          rails_den new community --database=postgresql
      HELP
    end
  end
end