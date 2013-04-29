# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'projektbauer/version'

Gem::Specification.new do |spec|
  spec.name          = "projektbauer"
  spec.version       = Projektbauer::VERSION
  spec.authors       = ["Bernhard Weichel"]
  spec.email         = ["github.com@nospam.weichel21.de"]
  spec.description   = %q{This gem creates and maintaines an SVN/Trac environment}
  spec.summary       = %q{Create an SVN/Trac environment}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency = "digest"
  
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "redcarpet"
  spec.add_development_dependency "wortsammler"
  spec.add_development_dependency "pry"
end
