require 'test/unit'
require File.dirname(__FILE__) + '/../lib/sbn4r'

class TestNet < Test::Unit::TestCase
  def setup
    @net       = Sbn::Net.new("Grass Wetness Belief Net")
    @cloudy    = Sbn::Variable.new(@net, :cloudy, [0.5, 0.5])
    @sprinkler = Sbn::Variable.new(@net, :sprinkler, [0.1, 0.9, 0.5, 0.5])
    @rain      = Sbn::Variable.new(@net, :rain, [0.8, 0.2, 0.2, 0.8])
    @grass_wet = Sbn::Variable.new(@net, :grass_wet, [0.99, 0.01, 0.9, 0.1, 0.9, 0.1, 0.0, 1.0])
    @cloudy.add_child(@sprinkler)
    @cloudy.add_child(@rain)
    @sprinkler.add_child(@grass_wet)
    @rain.add_child(@grass_wet)
    @evidence = {:sprinkler => :false, :rain => :true}
  end
  
  def teardown
  end
  
  def test_mcmc_inference
    @net.set_evidence @evidence
    probs = @net.query_variable(:grass_wet)
    assert_in_delta(probs[:true], 0.9, 0.1)
    assert_in_delta(probs[:false], 0.1, 0.1)
    
    probs = @net.query_variable(:cloudy)
    assert_in_delta(probs[:true], 0.8780487804878049, 0.1)
    assert_in_delta(probs[:false], 0.12195121951219512, 0.1)
    
    @evidence = {}
    @net.set_evidence(@evidence)
 
    probs = @net.query_variable(:cloudy)
    assert_in_delta(probs[:true], 0.5, 0.1)
    assert_in_delta(probs[:false], 0.5, 0.1)
 
    probs = @net.query_variable(:sprinkler)
    assert_in_delta(probs[:true], 0.3, 0.1)
    assert_in_delta(probs[:false], 0.7, 0.1)
    
    probs = @net.query_variable(:rain)
    assert_in_delta(probs[:true], 0.5, 0.1)
    assert_in_delta(probs[:false], 0.5, 0.1)

    probs = @net.query_variable(:grass_wet)
    assert_in_delta(probs[:true], 0.6471, 0.1)
    assert_in_delta(probs[:false], 0.3529, 0.1)
  end
  
  def test_import_export
    output = @net.to_xmlbif
    newnet = Sbn::Net.from_xmlbif(output)
    assert_equal @net, newnet
  end
end