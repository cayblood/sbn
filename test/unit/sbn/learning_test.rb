require 'test_helper'

class LearningTest < Minitest::Test # :nodoc:

  def setup
    @net = Sbn::Net.new("Categorization")
    @category = Sbn::Variable.new(@net, :category, [0.33, 0.33, 0.33], [:food, :groceries, :gas])
    @text = Sbn::StringVariable.new(@net, :text)
    @category.add_child(@text)
  end
  
  def test_string_learning
    @net.learn([
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
  
  def test_is_complete_evidence_eh
    assert !@text.is_complete_evidence?({})
    assert !@text.is_complete_evidence?(:text => "doughnuts")
    assert @text.is_complete_evidence?(:text => "doughnuts", :category => :food)    
  end

  def test_var_add_sample_point
    assert_raises(RuntimeError) { @category.add_sample_point(:text => "apples") }
    
    # we have to add at least one sample point to initialize the container
    @category.add_sample_point(:category => :groceries, :text => "albertsons")
    sample_point = {:category => :gas, :text => "gas n go"}
    sample_points = @category.instance_variable_get('@sample_points')
    assert !sample_points.include?(sample_point)
    @category.add_sample_point(sample_point)
    assert sample_points.include?(sample_point)
  end

  def test_var_set_probabilities_from_sample_points
    # test regular variable
    @category.add_sample_point(:category => :food, :text => "foo")
    @category.add_sample_point(:category => :food, :text => "foo")
    @category.add_sample_point(:category => :groceries, :text => 'gro')
    @category.add_sample_point(:category => :gas, :text => 'gas')
    @category.set_probabilities_from_sample_points!
    prob_table = @category.instance_variable_get('@probability_table')
    assert_equal prob_table.transpose.last, [0.4999, 0.2499, 0.2499]
    
    # test numeric variable
    basicvar = Sbn::Variable.new(@net, :basicvar)
    numvar = Sbn::NumericVariable.new(@net, :numvar)
    numvar.add_parent(basicvar)
    numvar.add_sample_point(:basicvar => :true, :numvar => 1.0)
    numvar.add_sample_point(:basicvar => :false, :numvar => 2.0)
    numvar.add_sample_point(:basicvar => :true, :numvar => 3.0)
    numvar.add_sample_point(:basicvar => :false, :numvar => 4.0)
    numvar.add_sample_point(:basicvar => :true, :numvar => 5.0)
    numvar.set_probabilities_from_sample_points!
    prob_table = numvar.instance_variable_get('@probability_table')
    probs = prob_table.transpose.last
    expected_probs = [0.0001, 0.0001, 0.333233333333333, 0.0001, 0.0001,
      0.0001, 0.0001, 0.0001, 0.0001, 0.0001, 0.333233333333333, 0.0001,
      0.0001, 0.0001, 0.0001, 0.0001, 0.0001, 0.0001, 0.0001, 0.333233333333333,
      0.0001, 0.0001, 0.0001, 0.0001, 0.0001, 0.0001, 0.0001, 0.4999,
      0.0001, 0.0001, 0.0001, 0.0001, 0.0001, 0.0001, 0.0001, 0.0001,
      0.4999, 0.0001, 0.0001, 0.0001, 0.0001, 0.0001]
    probs.each {|p| assert_in_delta(p, expected_probs.shift, 0.001) }

    @net.query_variable(:numvar)
  end

  def test_accumulate_state_frequencies
    @category.add_sample_point(:category => :food, :text => "foo")
    @category.add_sample_point(:category => :food, :text => "foo")
    @category.add_sample_point(:category => :groceries, :text => 'gro')
    @category.add_sample_point(:category => :gas, :text => 'gas')
    @category.instance_eval('accumulate_state_frequencies')
    freq = @category.instance_variable_get('@state_frequencies')
    assert_equal(freq, {[:groceries] => 1, [:gas] => 1, [:food] => 2})
  end
end
