begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
require 'rake/testtask'
require 'sbn'

Bundler::GemHelper.install_tasks

Rake::TestTask.new do |t|
  t.libs << "lib"
  t.libs << "test"
  t.test_files = FileList['test/**/{*_test.rb,*_spec.rb}']
  t.verbose = false
end

task :doc do
  exec "rdoc --quiet --main README.rdoc --exclude test* README.rdoc lib/*"
end

desc "Start a REPL session"
task :console do
  require 'pry'
  Pry.start
end
