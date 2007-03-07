require 'test/unit'
require File.dirname(__FILE__) + '/../lib/sbn'

class TestTraining < Test::Unit::TestCase # :nodoc:
  def setup
    @net = Sbn::Net.new("Categorization")
    @category = Sbn::Variable.new(@net, :category, [0.33, 0.33, 0.33], [:food, :groceries, :gas])
    @text = Sbn::StringVariable.new(@net, :text)
    @category.add_child(@text)
  end
  
  def test_string_training
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
  
  def test_is_complete_evidence_eh
    assert !@text.is_complete_evidence?({})
    assert !@text.is_complete_evidence?(:text => "doughnuts")
    assert @text.is_complete_evidence?(:text => "doughnuts", :category => :food)    
  end

  def test_var_add_training_set
    assert_raise(RuntimeError) { @category.add_training_set(:text => "apples") }
    
    # we have to add at least one training set to initialize the container
    @category.add_training_set(:category => :groceries, :text => "albertsons")
    training_set = {:category => :gas, :text => "gas n go"}
    training_data = @category.instance_variable_get('@training_data')
    assert !training_data.include?(training_set)
    @category.add_training_set(training_set)
    assert training_data.include?(training_set)
  end

  def test_var_set_probabilities_from_training_data
    # test regular variable
    @category.add_training_set(:category => :food, :text => "foo")
    @category.add_training_set(:category => :food, :text => "foo")
    @category.add_training_set(:category => :groceries, :text => 'gro')
    @category.add_training_set(:category => :gas, :text => 'gas')
    @category.set_probabilities_from_training_data
    prob_table = @category.instance_variable_get('@probability_table')
    assert_equal prob_table.transpose.last, [0.5, 0.25, 0.25]
    
    # test numeric variable
    basicvar = Sbn::Variable.new(@net, :basicvar)
    numvar = Sbn::NumericVariable.new(@net, :numvar)
    numvar.add_parent(basicvar)
    numvar.add_training_set(:basicvar => :true, :numvar => 1.0)
    numvar.add_training_set(:basicvar => :false, :numvar => 2.0)
    numvar.add_training_set(:basicvar => :true, :numvar => 3.0)
    numvar.add_training_set(:basicvar => :false, :numvar => 4.0)
    numvar.add_training_set(:basicvar => :true, :numvar => 5.0)
    numvar.set_probabilities_from_training_data
    prob_table = numvar.instance_variable_get('@probability_table')
    probs = prob_table.transpose.last
    expected_probs = [0.0001, 0.0001, 0.19926, 0.0001, 0.0001, 0.0001,
     0.0001, 0.0001, 0.0001, 0.0001, 0.19926, 0.0001, 0.0001, 0.0001,
     0.0001, 0.0001, 0.0001, 0.0001, 0.0001, 0.19926, 0.0001, 0.0001,
     0.0001, 0.0001, 0.0001, 0.0001, 0.0001, 0.19926, 0.0001, 0.0001,
     0.0001, 0.0001, 0.0001, 0.0001, 0.0001, 0.0001, 0.19926, 0.0001,
     0.0001, 0.0001, 0.0001, 0.0001]
    probs.each {|p| assert_in_delta(p, expected_probs.shift, 0.001) }
  end

  def test_accumulate_state_frequencies
    @category.add_training_set(:category => :food, :text => "foo")
    @category.add_training_set(:category => :food, :text => "foo")
    @category.add_training_set(:category => :groceries, :text => 'gro')
    @category.add_training_set(:category => :gas, :text => 'gas')
    @category.instance_eval('accumulate_state_frequencies')
    freq = @category.instance_variable_get('@state_frequencies')
    assert_equal(freq, {[:groceries] => 1, [:gas] => 1, [:food] => 2})
  end

  def test_net_add_training_set
    set = {:category => :food, :text => "foo"}
    @net.add_training_set(set)
    variables = @net.instance_variable_get('@variables')
    variables.each do |key, var|
      training_data = var.instance_variable_get('@training_data')
      assert training_data.include?(set) if training_data
    end
  end
end