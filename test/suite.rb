require 'test/unit'
files = Dir[File.dirname(__FILE__) + '/*.rb']
files.each do |f|
  require f unless f =~ /suite/
end