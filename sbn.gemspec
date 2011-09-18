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
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rake",          "~> 0.9.2"
  s.add_runtime_dependency     "builder",       "~> 3.0.0"
  s.add_runtime_dependency     "xml-simple",    "~> 1.1.0"
  s.add_runtime_dependency     "i18n",          "~> 0.6.0"
  s.add_runtime_dependency     "activesupport", "~> 3.1.0"
end
