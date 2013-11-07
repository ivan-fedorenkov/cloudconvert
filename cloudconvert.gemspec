# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cloudconvert/version'

Gem::Specification.new do |spec|
  spec.name          = "cloudconvert"
  spec.version       = Cloudconvert::VERSION
  spec.authors       = ["killergti"]
  spec.email         = ["ivan.fedorenkov@gmail.com"]
  spec.description   = %q{This is an utility gem for interacting with cloudconvert.org API}
  spec.summary       = %q{Interacts with cloudconvert API, using Net::HTTP}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency "multipart-post", "~> 1.2.0"
end
