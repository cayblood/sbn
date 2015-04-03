begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
require 'rake/testtask'

Bundler::GemHelper.install_tasks

Rake::TestTask.new do |t|
  t.libs << "lib"
  t.libs << "test"
  t.test_files = FileList['test/**/test*.rb']
  t.verbose = false
end

task :doc do
  exec "rdoc --quiet --main README.rdoc --exclude test* README.rdoc lib/*"
end
