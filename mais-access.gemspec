lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
	spec.name          = "mais-access"
	spec.version       = "1.0.3"
	spec.platform      = Gem::Platform::RUBY
	spec.author        = "Elias Gabriel"
	spec.email         = "me@eliasfgabriel.com"
	spec.summary       = "A simple MAIS authentication app."
	spec.description   = "A simple gem that provides HTTP Basic Authentication for users registered with the `mais ~ accounts` application."
	spec.homepage      = "https://github.com/sdbase/mais-access"
	spec.license       = "BSD-3-Clause"

	spec.metadata["homepage_uri"] = spec.metadata["source_code_uri"] = spec.homepage
	spec.extra_rdoc_files = ["README.md"]

	spec.require_paths = ["lib"]
	spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
		`git ls-files -z`.split("\x0")
	end

	spec.add_dependency "rails", '>= 4.0.2'

	spec.add_development_dependency "bundler", '~> 2.0'
	spec.add_development_dependency "rake", '~> 10.0'
end