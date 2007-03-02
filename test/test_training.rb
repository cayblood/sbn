require 'test/unit'
require File.dirname(__FILE__) + '/../lib/sbn4r'

class TrainingTest < Test::Unit::TestCase
  def setup
    @net = Sbn::Net.new("Categorization")
    @category = Sbn::Variable.new(@net, :category, [0.33, 0.33, 0.33], [:food, :groceries, :gas])
    @text = Sbn::StringVariable.new(@net, :text)
    @category.add_child(@text)
  end
  
  def teardown
  end

  def test_training
    @net.train([
      {:category => :food, :text => 'foo'},
      {:category => :food, :text => 'gro'},
      {:category => :food, :text => 'foo'},
      {:category => :food, :text => 'foo'},
      {:category => :groceries, :text => 'gro'},
      {:category => :groceries, :text => 'gro'},
      {:category => :groceries, :text => 'foo'},
      {:category => :groceries, :text => 'gro'},
      {:category => :gas, :text => 'gas'},
      {:category => :gas, :text => 'gas'},
      {:category => :gas, :text => 'gas'},
      {:category => :gas, :text => 'gas'}
    ])
    probs = @category.probability_table.dup
    food_prob = probs.shift.pop
    groceries_prob = probs.shift.pop
    gas_prob = probs.shift.pop
    assert_in_delta food_prob, 0.333, 0.001
    assert_in_delta groceries_prob, 0.333, 0.001
    assert_in_delta gas_prob, 0.333, 0.001
  end
end