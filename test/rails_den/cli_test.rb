require "test_helper"
require "rails_den/cli"
require "stringio"

module RailsDen
  class CLITest < ActiveSupport::TestCase
    test "help describes the new and install views commands" do
      out = StringIO.new
      err = StringIO.new

      status = RailsDen::CLI.start(
        ["--help"],
        out: out,
        err: err
      )

      assert_equal 0, status
      assert_includes out.string, "rails_den new NAME"
      assert_includes out.string, "rails_den install:views"
      assert_includes out.string, "--force"
      assert_empty err.string
    end

    test "version returns the RailsDen version" do
      out = StringIO.new
      err = StringIO.new

      status = RailsDen::CLI.start(
        ["--version"],
        out: out,
        err: err
      )

      assert_equal 0, status
      assert_equal "#{RailsDen::VERSION}\n", out.string
      assert_empty err.string
    end

    test "unknown command returns an error" do
      out = StringIO.new
      err = StringIO.new

      status = RailsDen::CLI.start(
        ["explode"],
        out: out,
        err: err
      )

      assert_equal 1, status
      assert_includes err.string, "Unknown command: explode"
    end

    test "new requires an application name" do
      out = StringIO.new
      err = StringIO.new

      status = RailsDen::CLI.start(
        ["new"],
        out: out,
        err: err
      )

      assert_equal 1, status
      assert_includes err.string, "Usage: rails_den new NAME"
    end

    test "default standalone template exists" do
      assert File.file?(RailsDen::CLI::DEFAULT_TEMPLATE_PATH)
    end

    test "new delegates to Rails with the RailsDen standalone template" do
      received_arguments = nil
      template_path = "/tmp/rails_den_standalone_template.rb"

      fake_generator = Class.new do
        define_singleton_method(:start) do |arguments|
          received_arguments = arguments
        end
      end

      status = RailsDen::CLI.start(
        [
          "new",
          "community",
          "--database=postgresql",
          "--skip-git"
        ],
        out: StringIO.new,
        err: StringIO.new,
        app_generator: fake_generator,
        template_path: template_path
      )

      assert_equal 0, status

      assert_equal(
        [
          "community",
          "--database=postgresql",
          "--skip-git",
          "--template=#{template_path}"
        ],
        received_arguments
      )
    end

    test "install views invokes the RailsDen view installer" do
      installed = nil

      fake_installer_class = Class.new do
        define_method(:initialize) do |destination_root:, out:|
        end

        define_method(:install) do |force:|
          installed = force
        end
      end

      status = RailsDen::CLI.start(
        ["install:views"],
        out: StringIO.new,
        err: StringIO.new,
        view_installer_class: fake_installer_class
      )

      assert_equal 0, status
      assert_equal false, installed
    end

    test "install views supports force" do
      installed = nil

      fake_installer_class = Class.new do
        define_method(:initialize) do |destination_root:, out:|
        end

        define_method(:install) do |force:|
          installed = force
        end
      end

      status = RailsDen::CLI.start(
        ["install:views", "--force"],
        out: StringIO.new,
        err: StringIO.new,
        view_installer_class: fake_installer_class
      )

      assert_equal 0, status
      assert_equal true, installed
    end

    test "install views rejects unknown options" do
      out = StringIO.new
      err = StringIO.new

      status = RailsDen::CLI.start(
        ["install:views", "--banana"],
        out: out,
        err: err
      )

      assert_equal 1, status
      assert_includes err.string, "Unknown option for install:views"
    end
  end
end