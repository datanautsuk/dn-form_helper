# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'datanauts/form_helper/version'

Gem::Specification.new do |spec|
  spec.name          = "dn-form_helper"
  spec.version       = Datanauts::FormHelper::VERSION
  spec.authors       = ["Jonathan Davies", "Simon Brook"]
  spec.email         = ["jonnie@obdev.co.uk", "simon@datanauts.co.uk"]
  spec.summary       = %q{Datanauts form helper}
  spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rack"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry-byebug"
end
