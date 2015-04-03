# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sbn/version"

Gem::Specification.new do |s|
  s.name        = "sbn"
  s.version     = Sbn::VERSION
  s.authors     = ["Carl Youngblood"]
  s.email       = ["carl@youngbloods.org"]
  s.homepage    = "http://github.com/cayblood/sbn"
  s.summary     = "Simple Bayesian Network Library"
  s.description = "SBN makes it easy to use Bayesian Networks in your ruby application."

  s.rubyforge_project = "sbn"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test/unit,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rake"
  s.add_development_dependency "minitest", "~> 5.0"
  s.add_development_dependency "pry"
  s.add_runtime_dependency     "builder"
  s.add_runtime_dependency     "xml-simple",    "~> 1.1.0"
  s.add_runtime_dependency     "i18n"
  s.add_runtime_dependency     "activesupport"
end
