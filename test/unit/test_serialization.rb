require 'test_helper'

class TestSerialization < Minitest::Test # :nodoc:

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
  end


  def test_json_serialization
    json = @net.to_json
    assert_equal "0.3", json[:version]
    assert_equal :json_test, json[:network][:name]
    json[:network].tap do |net|
      assert_equal 2, net[:variables].count
    end
  end

  def test_json_loading
    loaded_net = Sbn::Net.from_json(@net.to_json)
    assert_equal :json_test, loaded_net.name
    assert_equal @net.variables.count, loaded_net.variables.count
    refute_equal @net.object_id, loaded_net.object_id

    [:basic_var, :num_var].each do |name|
      original, loaded = @net.variables[name], loaded_net.variables[name]
      refute_equal original.object_id, loaded.object_id
      assert_equal original.name, loaded.name
      assert_equal original.probabilities, loaded.probabilities
      assert_equal original.probability_table, loaded.probability_table
    end
  end

  def test_num_var_json
    json = @num_var.to_json_variable
    assert_equal false, json[:parents].empty?
  end

end