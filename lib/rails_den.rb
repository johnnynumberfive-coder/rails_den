require "simple_form"

require "rails_den/version"
require "rails_den/configuration"
require "rails_den/engine"

module RailsDen
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    alias_method :config, :configuration

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end