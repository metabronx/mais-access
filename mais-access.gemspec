# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name = "mais-access"
  spec.version     = "2.1.1"
  spec.author      = "Elias Gabriel"
  spec.email       = "me@eliasfgabriel.com"
  spec.homepage    = "https://github.com/sdbase/mais-access"
  spec.license     = "CC-BY-NC-SA-4.0"

  spec.summary     = "Provides a HTTP/JWT authentication middleware."
  spec.description = <<~HEREDOC.gsub(/[[:space:]]+/, " ").strip
    mais-access provides a simple yet secure HTTP(S) authentication barrier for
    applications developed within the MAIS system. After initial connection, sessions
    for authenticated clients are validated by JSON Web Tokens for reduced overhead and
    improved security.
  HEREDOC

  spec.metadata    = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
    "bug_tracker_uri" => "#{spec.homepage}/issues"
  }

  spec.required_ruby_version = ">= 2.4.0"

  spec.add_dependency "rails", "~> 5.2"
  spec.add_dependency "rake", ">= 12.3.3"

  spec.add_development_dependency "practical-pig", "~> 1.0"
  spec.add_development_dependency "rubocop", "~> 0.83.0"
  spec.add_development_dependency "rubocop-minitest", "~> 0.9"
  spec.add_development_dependency "rubocop-performance", "~> 1.3"
  spec.add_development_dependency "rubocop-rails", "~> 2.5"

  spec.files = `git ls-files`.split("\n")
  # spec.test_files  = `git ls-files -- test/*`.split("\n")
end
