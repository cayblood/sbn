require 'test/unit'
require File.dirname(__FILE__) + '/../lib/sbn4r'

class TestCombination < Test::Unit::TestCase # :nodoc:
  def setup
    @c = Combination.new([[1, 2], [3, 4, 5]])
  end

  def test_current
    test_first
    test_last
  end

  def test_each
    @c.first
    combinations = [[1, 3], [1, 4], [1, 5], [2, 3], [2, 4], [2, 5]]
    index = 0
    @c.each do |comb|
      assert_equal combinations[index], comb
      index += 1
    end
  end

  def test_first
    @c.first
    assert_equal @c.current, [1, 3]
  end

  def test_last
    @c.last
    assert_equal @c.current, [2, 5]
  end

  def test_next_combination
    @c.first
    assert_equal @c.next_combination, [1, 4]
    assert_equal @c.next_combination, [1, 5]
    assert_equal @c.next_combination, [2, 3]
    assert_equal @c.next_combination, [2, 4]
    assert_equal @c.next_combination, [2, 5]
  end

  def test_prev_combination
    @c.last
    assert_equal @c.prev_combination, [2, 4]
    assert_equal @c.prev_combination, [2, 3]
    assert_equal @c.prev_combination, [1, 5]
    assert_equal @c.prev_combination, [1, 4]
    assert_equal @c.prev_combination, [1, 3]
  end
end