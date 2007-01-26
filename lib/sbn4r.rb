require 'rubygems'
require 'active_support'

Dir[File.join(File.dirname(__FILE__), '*.rb')].sort.each { |lib| require lib unless lib == 'sbn4r.rb' }