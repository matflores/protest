# -*- coding: utf-8 -*-

require "./lib/protest/version"

Gem::Specification.new do |s|
  s.name          = "protest"
  s.version       = Protest::VERSION
  s.summary       = "Protest is a tiny, simple, and easy-to-extend test framework"
  s.description   = "Protest is a tiny, simple, and easy-to-extend test framework for ruby."
  s.homepage      = "http://protestrb.com"
  s.authors       = ["Nicolás Sanguinetti", "Matías Flores"]
  s.email         = "flores.matias@gmail.com"
  s.require_paths = ["lib"]
  s.files         = %w{ .gitignore CHANGELOG.md LICENSE README.md Rakefile protest.gemspec }
  s.files        += Dir["lib/**/*.rb"]
end
