# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bunto-github-metadata/version'

Gem::Specification.new do |spec|
  spec.name          = "bunto-github-metadata"
  spec.version       = Bunto::GitHubMetadata::VERSION
  spec.authors       = ["Parker Moore", "Suriyaa Kudo"]
  spec.email         = ["parkrmoore@gmail.com", "SuriyaaKudoIsc@users.noreply.github.com"]
  spec.summary       = %q{The site.github namespace}
  spec.homepage      = "https://github.com/bunto/github-metadata"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").grep(%r{^(lib|bin)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "octokit", "~> 4.0"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "netrc"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "bunto", ENV["BUNTO_VERSION"] ? "~> #{ENV["BUNTO_VERSION"]}" : "~> 1.0"
  spec.add_development_dependency "github-pages", ENV["GITHUB_PAGES"] if ENV["GITHUB_PAGES"]
end
