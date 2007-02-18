require 'test/unit'
require File.dirname(__FILE__) + '/../lib/sbn4r'

class VariableTest < Test::Unit::TestCase
  def setup
  end
  
  def teardown
  end
  
  def test_set_probability
    n = Sbn::Variable.new('george', ['good', 'bad'])
    n.set_probability(0.5, :george => :good)
    n.set_probability(0.5, :george => :bad)
  end
  
  def test_get_random_state
    n = Sbn::Variable.new('george', ['good', 'bad', 'ugly'], [0.25, 0.25, 0.5])
    assert true
  end
end