# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name        = "mais-access"
  spec.version     = "2.1.2"
  spec.author      = "Elias Gabriel"
  spec.email       = "me@eliasfgabriel.com"
  spec.homepage    = "https://github.com/metabronx/mais-access"
  spec.license     = "CC-BY-NC-SA-4.0"

  spec.summary     = "Provides an HTTP/JWT authentication middleware."
  spec.description = <<~HEREDOC.gsub(/[[:space:]]+/, " ").strip
    mais-access provides a simple yet secure HTTP(S) authentication barrier for
    applications developed within the MAIS system. After initial connection, sessions
    for authenticated clients are validated by JSON Web Tokens for reduced overhead and
    improved security.
  HEREDOC

  spec.metadata    = {
    "homepage_uri" => "https://www.metabronx.com",
    "source_code_uri" => spec.homepage,
    "bug_tracker_uri" => "#{spec.homepage}/issues",
    "rubygems_mfa_required" => "true",
    "funding_uri" => "https://www.metabronx.com/invest"
  }

  spec.required_ruby_version = ">= 2.4.0"

  spec.add_dependency "rails", "~> 5.2"
  spec.add_dependency "rake", ">= 12.3.3"

  spec.add_development_dependency "practical-pig", "~> 1.0"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-minitest"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "rubocop-rails"

  spec.files = `git ls-files lib/`.split("\n")
end
