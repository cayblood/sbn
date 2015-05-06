require 'test_helper'

class NumericVariableTest < Minitest::Test # :nodoc:

  def setup
    @net = Sbn::Net.new
    @var1 = Sbn::NumericVariable.new(@net, "var1", [0.25, 0.25, 0.25, 0.25], [5.0, 10.0, 15.0])
  end

  def test_get_observed_state
    evidence = {:var1 => 7.68}
    states = @var1.states
    assert_equal @var1.get_observed_state(evidence), states[1]
  end

  def test_set_probabilities_from_sample_points
    data = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    temp_data = data.dup
    @var1.add_sample_point({:var1 => temp_data.shift})
    @var1.add_sample_point({:var1 => temp_data.shift})
    @var1.add_sample_point({:var1 => temp_data.shift})
    @var1.add_sample_point({:var1 => temp_data.shift})
    @var1.add_sample_point({:var1 => temp_data.shift})
    @var1.add_sample_point({:var1 => temp_data.shift})
    @var1.add_sample_point({:var1 => temp_data.shift})
    @var1.add_sample_point({:var1 => temp_data.shift})
    @var1.add_sample_point({:var1 => temp_data.shift})
    @var1.add_sample_point({:var1 => temp_data.shift})
    @var1.add_sample_point({:var1 => temp_data.shift})
    @var1.set_probabilities_from_sample_points!
    assert_equal @var1.state_thresholds.shift, data.average - (data.standard_deviation * 2.0)
  end

  def test_state_thresholds
    assert_equal @var1.state_thresholds, [5.0, 10.0, 15.0]
  end

  def test_to_xmlbif_variable
    xml = Builder::XmlMarkup.new(:indent => 2)
    expected_output = <<-EOS
    <variable type="nature">
      <name>var1</name>
      <outcome>lt5.0</outcome>
      <outcome>gte5.0lt10.0</outcome>
      <outcome>gte10.0lt15.0</outcome>
      <outcome>gte15.0</outcome>
      <property>SbnVariableType = Sbn::NumericVariable</property>
      <property>StateThresholds = 5.0,10.0,15.0</property>
    </variable>
    EOS
    assert_equal @var1.to_xmlbif_variable(xml).gsub(/\s+/, ''), expected_output.gsub(/\s+/, '')
  end

end