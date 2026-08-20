require_relative "lib/rails_den/version"

Gem::Specification.new do |spec|
  spec.name        = "rails_den"
  spec.version     = RailsDen::VERSION
  spec.authors     = [ "Oak Harbor Ventures, LLC" ]
  spec.email       = [ "John Nelson" ]
  spec.homepage    = "https://support.oakharborventures.com"
  spec.summary     = "TODO: Summary of RailsDen."
  spec.description = "TODO: Description of RailsDen."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.bindir = "exe"
  spec.executables = [ "rails_den" ]

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir[
      "{app,config,db,exe,lib}/**/*",
      "MIT-LICENSE",
      "Rakefile",
      "README.md"
    ]
  end

  spec.add_dependency "rails", ">= 8.1.3.1"
  spec.add_dependency "simple_form", ">= 5.4.1"
  spec.add_dependency "administrate", "~> 1.0"
end