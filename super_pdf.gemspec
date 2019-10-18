# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'super_pdf/version'

Gem::Specification.new do |spec|
  spec.name          = "super_pdf"
  spec.version       = SuperPDF::VERSION
  spec.authors       = ["vegeta"]
  spec.email         = ["phyala@gmail.com"]

  spec.summary       = "Super PDF"
  spec.description   = "A simple pdf enhance module."
  spec.homepage      = "https://github.com/superlanding/super_pdf"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "mocha", "~> 1.9"
  spec.add_dependency "activesupport", "~> 4"
  spec.add_dependency "prawn", "~> 2.2", '>= 2.2.2'
  spec.add_dependency "prawn-table", "0.2.2"
  spec.add_dependency "prawn-icon", "2.4.0"
end
