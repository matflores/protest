# -*- coding: utf-8 -*-

require "./lib/protest/version"

Gem::Specification.new do |s|
  s.name    = "protest"
  s.version = Protest::VERSION
  s.date    = "2010-10-22"

  s.description = "Protest is a tiny, simple, and easy-to-extend test framework"
  s.summary     = s.description
  s.homepage    = "http://protestrb.com"

  s.authors = ["Nicolás Sanguinetti", "Matías Flores"]
  s.email   = "mflores@atlanware.com"

  s.require_paths     = ["lib"]
  s.rubyforge_project = "protest"
  s.rubygems_version  = "1.3.1"

  s.files = %w[
.gitignore
LICENSE
README.md
Rakefile
protest.gemspec
lib/protest.rb
lib/protest/utils.rb
lib/protest/utils/backtrace_filter.rb
lib/protest/utils/summaries.rb
lib/protest/utils/colorful_output.rb
lib/protest/test_case.rb
lib/protest/tests.rb
lib/protest/runner.rb
lib/protest/report.rb
lib/protest/reports.rb
lib/protest/reports/progress.rb
lib/protest/reports/documentation.rb
lib/protest/reports/summary.rb
lib/protest/reports/turn.rb
]
end
