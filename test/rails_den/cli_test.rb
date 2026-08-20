require "test_helper"
require "rails_den/cli"
require "stringio"

module RailsDen
  class CLITest < ActiveSupport::TestCase
    test "help returns success and describes the new command" do
      out = StringIO.new
      err = StringIO.new

      status = RailsDen::CLI.start(
        ["--help"],
        out: out,
        err: err
      )

      assert_equal 0, status
      assert_includes out.string, "rails_den new NAME"
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

    test "new delegates to the Rails application generator" do
      received_arguments = nil

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
        app_generator: fake_generator
      )

      assert_equal 0, status

      assert_equal(
        [
          "community",
          "--database=postgresql",
          "--skip-git"
        ],
        received_arguments
      )
    end
  end
end