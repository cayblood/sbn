require 'test/unit'
require 'rubygems'

Gem::manage_gems
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.name              = "sbn"
  s.version           = "0.9.0"
  s.author            = "Carl Youngblood"
  s.email             = "carl@youngbloods.org"
  s.homepage          = "http://youngbloods.org/"
  s.platform          = Gem::Platform::RUBY
  s.summary           = "Simple Bayesian Network Library"
  s.files             = FileList["{test,lib}/**/*"].to_a
  s.require_path      = 'lib'
  s.autorequire       = 'sbn'
  s.test_file         = 'test/sbn.rb'
  s.has_rdoc          = true
  s.rdoc_options      << '--main' << 'README'
  s.extra_rdoc_files  = ["README"]
end

Rake::GemPackageTask.new(spec) {|pkg| pkg.need_tar = true }

task :default => :test

task :test do
  exec "ruby test/sbn.rb"
end

task :doc do
  exec "rdoc --quiet --main README --exclude test* README lib/*"
end