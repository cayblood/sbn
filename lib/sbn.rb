require 'rubygems'
require 'active_support'
gem 'builder', '>=2.0'
require 'builder'

Dir[File.join(File.dirname(__FILE__), '*.rb')].sort.each { |lib| require lib unless lib == 'sbn.rb' }