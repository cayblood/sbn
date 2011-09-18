require "bundler/gem_tasks"

task :default => :test

task :test do
  exec "testrb test"
end

task :doc do
  exec "rdoc --quiet --main README --exclude test* README lib/*"
end