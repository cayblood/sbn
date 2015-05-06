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

  def test_set_probabilities_from_sample_points
    sampled = Sbn::NumericVariable.new(@net, "sampled")
    data = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    data.each { |v| sampled.add_sample_point({:sampled => v}) }
    sampled.set_probabilities_from_sample_points!
    assert_equal sampled.state_thresholds.shift, data.average - (data.standard_deviation * 2.0)
  end

  def test_user_specified_state_thresholds
    user_threshold = Sbn::NumericVariable.new(@net, "user_threshold", [], [0, 5, 10])
    [1.0, 8, 11].each { |point| user_threshold.add_sample_point(user_threshold: point) }
    user_threshold.set_probabilities_from_sample_points!
    
    assert_equal [:lt0, :gte0lt5, :gte5lt10, :gte10], user_threshold.states
    assert_equal :lt0, user_threshold.get_observed_state(user_threshold: -2)
    assert_equal :gte0lt5, user_threshold.get_observed_state(user_threshold: 3)
    assert_equal :gte5lt10, user_threshold.get_observed_state(user_threshold: 7)
    assert_equal :gte10, user_threshold.get_observed_state(user_threshold: 12)
  end

  def test_lower_bound_option
    unbounded = Sbn::NumericVariable.new(@net, "unbounded")
    lower_bound = Sbn::NumericVariable.new(@net, "lower_bound", [], [], lower_bound: 0)
    nodes = [unbounded, lower_bound]
    [ 1.0, 3.0].each do |point|
      nodes.each { |n| n.add_sample_point n.name => point }
    end
    nodes.each(&:set_probabilities_from_sample_points!)
    assert_equal 21, unbounded.states.count
    assert_equal 18, lower_bound.states.count
  end

end