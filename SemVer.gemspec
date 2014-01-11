# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'SemVer/version'

Gem::Specification.new do |spec|
  spec.name          = "SemVer"
  spec.version       = SemVer::VERSION
  spec.authors       = ["Thomas Holmes"]
  spec.email         = ["thomas@holmes.io"]
  spec.summary       = %q{SemVer is a library for managing semantic versions}
  spec.description   = %q{Manage semantic versioning. Read more on semantic versioning at http://semver.org}
  spec.homepage      = "http://github.com/thomas-holmes/semver"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0.0.beta1"
end
