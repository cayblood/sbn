require 'test_helper'

class SerializationTest < Minitest::Test # :nodoc:

  def setup
    @net = Sbn::Net.new("JSON Test")
    basic_var = Sbn::Variable.new(@net, :basic_var)
    @num_var = Sbn::NumericVariable.new(@net, :num_var)
    @num_var.add_parent(basic_var)
    @num_var.add_sample_point(basic_var: :true, num_var: 1.0)
    @num_var.add_sample_point(basic_var: :false, num_var: 2.0)
    @num_var.add_sample_point(basic_var: :true, num_var: 3.0)
    @num_var.add_sample_point(basic_var: :false, num_var: 4.0)
    @num_var.add_sample_point(basic_var: :true, num_var: 5.0)
    @net.set_probabilities_from_sample_points!
    @loaded_net = Sbn::Net.from_json(@net.to_json)
  end

  def test_json_serialization
    json = @net.to_json
    assert_equal "0.3", json[:version]
    assert_equal :json_test, json[:network][:name]
    json[:network].tap do |net|
      assert_equal 2, net[:variables].count
    end
  end

  def test_json_net_loading
    assert_equal :json_test, @loaded_net.name
    assert_equal @net.variables.count, @loaded_net.variables.count
    refute_equal @net.object_id, @loaded_net.object_id
  end

  def test_json_loading_variables
    original, loaded = @net.variables[:basic_var], @loaded_net.variables[:basic_var]
    assert_basic_serialization original, loaded
    assert_equal 1, loaded.children.count
    assert_equal @loaded_net.variables[:num_var].object_id, loaded.children.last.object_id
  end

  def test_json_loading_numeric_variables
    original, loaded = @net.variables[:num_var], @loaded_net.variables[:num_var]
    assert_basic_serialization original, loaded
    assert_equal 1, loaded.parents.count
    assert_equal @loaded_net.variables[:basic_var].object_id, loaded.parents.last.object_id
  end

  protected

  def assert_basic_serialization(original, loaded)
    refute_equal original.object_id, loaded.object_id
    assert_equal original.name, loaded.name
    assert_equal original.probabilities, loaded.probabilities
    assert_equal original.probability_table, loaded.probability_table
    assert_equal original.class, loaded.class
  end

end