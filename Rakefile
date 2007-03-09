require 'test/unit'
require 'rubygems'

Gem::manage_gems
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.name         = "SBN"
  s.version      = 0.9.0
  s.author       = "Carl Youngblood"
  s.email        = "carl@youngbloods.org"
  s.homepage     = "http://youngbloods.org/"
  s.platform     = Gem::Platform::RUBY
  s.summary      = "A library for working with Bayesian Networks"
  s.files        = FileList["{test,lib,docs}/**/*"].exclude("")

task :default => :test

task :test do
  exec "ruby test/sbn.rb"
end

task :doc do
  exec "rdoc --quiet --main README --exclude test* README lib/*"
end