require 'test/unit'
require File.dirname(__FILE__) + '/../lib/sbn4r'

class CombinationTest < Test::Unit::TestCase
  def setup
    @c = Combination.new([[:bear, :badger], [:stork, :bluegill, :beetle], [:fig, :grape]])
  end
  
  def teardown
  end
  
  def test_each
    assert true
  end
  
  def test_comparison
    c1 = Combination.new([[1, 2], [3, 4, 5]])
    assert true
  end
end