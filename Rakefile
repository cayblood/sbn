require 'test/unit'

task :default => :test

task :test do
  exec "ruby test/sbn4r.rb"
end

task :doc do
  exec "rdoc --quiet --main Sbn --exclude test*"
end