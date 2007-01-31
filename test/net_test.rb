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
  end
  
  def teardown
  end
  
  def test_mcmc_inference
    @net.set_evidence :sprinkler => :false, :rain => :true
    probs = @net.query_node(:grass_wet)
    assert (probs[:true] * 10).round == 9.0
    assert (probs[:false] * 10).round == 1.0
    probs = @net.query_node(:cloudy)
    p probs
    assert (probs[:true] * 100).round == 88
    assert (probs[:false] * 100).round == 12
  end
  
  def test_import_export
    output = @net.to_xmlbif
    newnet = Sbn::Net.from_xmlbif(output)
    assert_equal @net, newnet
  end
end