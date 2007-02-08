require 'test/unit'
require File.dirname(__FILE__) + '/../lib/sbn4r'

class NetTest < Test::Unit::TestCase
  def setup
    @net       = Sbn::Net.new("Grass Wetness Belief Net")
    @cloudy    = Sbn::Node.new(:cloudy, [:true, :false], [0.5, 0.5])
    @sprinkler = Sbn::Node.new(:sprinkler, [:true, :false], [0.1, 0.9, 0.5, 0.5])
    @rain      = Sbn::Node.new(:rain, [:true, :false], [0.8, 0.2, 0.2, 0.8])
    @grass_wet = Sbn::Node.new(:grass_wet, [:true, :false], [0.99, 0.01, 0.9, 0.1, 0.9, 0.1, 0.0, 1.0])
    @net << [@cloudy, @sprinkler, @rain, @grass_wet]
    @cloudy.add_child(@sprinkler)
    @cloudy.add_child(@rain)
    @sprinkler.add_child(@grass_wet)
    @rain.add_child(@grass_wet)
    @evidence = {:sprinkler => :false, :rain => :true}
  end
  
  def teardown
  end
  
  def test_is_explained_away?
    @net.set_evidence @evidence
    assert @grass_wet.is_explained_away?(@cloudy, @evidence)
  end
  
  def test_mcmc_inference
    @net.set_evidence @evidence
    probs = @net.query_node(:grass_wet)
    assert (probs[:true] * 10).round == 9.0
    assert (probs[:false] * 10).round == 1.0
    probs = @net.query_node(:cloudy)
    rounded_true_prob = (probs[:true] * 100).round
    rounded_false_prob = (probs[:false] * 100).round
    assert rounded_true_prob >= 86 and rounded_true_prob <= 90
    assert rounded_false_prob >= 10 and rounded_false_prob <= 14
    @evidence = {}
    @net.set_evidence(@evidence)
    probs = @net.query_node(:sprinkler)
    rounded_true_prob = (probs[:true] * 100).round
    rounded_false_prob = (probs[:false] * 100).round
    assert rounded_true_prob >= 28 and rounded_true_prob <= 32
    assert rounded_false_prob >= 68 and rounded_false_prob <= 72
  end
  
  def test_import_export
    output = @net.to_xmlbif
    newnet = Sbn::Net.from_xmlbif(output)
    assert_equal @net, newnet
  end
end