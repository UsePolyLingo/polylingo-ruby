# frozen_string_literal: true

require_relative "lib/polylingo/version"

Gem::Specification.new do |spec|
  spec.name = "polylingo"
  spec.version = PolyLingo::VERSION
  spec.authors = ["PolyLingo"]
  spec.email = ["hello@usepolylingo.com"]

  spec.summary = "Ruby client for the PolyLingo translation API"
  spec.description = "Ruby client for the PolyLingo translation API (https://usepolylingo.com)."
  spec.homepage = "https://github.com/UsePolyLingo/polylingo-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec|\.github)/}) }
  rescue StandardError
    Dir["lib/**/*", "LICENSE", "*.md", "polylingo.gemspec"]
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "webmock", "~> 3.19"
end
