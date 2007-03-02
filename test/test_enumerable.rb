require 'test/unit'
require File.dirname(__FILE__) + '/../lib/sbn4r'

class TestEnumerable < Test::Unit::TestCase       # :nodoc: all
  def test_sum
    assert_equal 45, (1..9).sum
  end

  def test_average
    # Ranges don't have a length
    assert_in_delta 5.0, (1..9).to_a.average, 0.01
  end

  def test_sample_variance
    assert_in_delta 6.6666, (1..9).to_a.sample_variance, 0.0001
  end

  def test_standard_deviation
    assert_in_delta 2.5819, (1..9).to_a.standard_deviation, 0.0001
  end
end