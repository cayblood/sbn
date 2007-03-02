require 'test/unit'
require File.dirname(__FILE__) + '/../lib/sbn4r'

class TestNet < Test::Unit::TestCase # :nodoc:
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
  
  def test_inference_on_grasswet_with_evidence_querying_grasswet
    @net.set_evidence @evidence
    probs = @net.query_variable(:grass_wet)
    assert_in_delta(probs[:true], 0.9, 0.1)
    assert_in_delta(probs[:false], 0.1, 0.1)
  end

  def test_inference_on_grasswet_with_evidence_querying_cloudy
    @net.set_evidence @evidence
    probs = @net.query_variable(:cloudy)
    assert_in_delta(probs[:true], 0.8780487804878049, 0.1)
    assert_in_delta(probs[:false], 0.12195121951219512, 0.1)
  end

  def test_inference_on_grasswet_without_evidence_querying_cloudy
    @evidence = {}
    @net.set_evidence @evidence
    probs = @net.query_variable(:cloudy)
    assert_in_delta(probs[:true], 0.5, 0.1)
    assert_in_delta(probs[:false], 0.5, 0.1)
  end

  def test_inference_on_grasswet_without_evidence_querying_sprinkler
    @evidence = {}
    @net.set_evidence @evidence
    probs = @net.query_variable(:sprinkler)
    assert_in_delta(probs[:true], 0.3, 0.1)
    assert_in_delta(probs[:false], 0.7, 0.1)
  end

  def test_inference_on_grasswet_without_evidence_querying_rain
    @evidence = {}
    @net.set_evidence @evidence
    probs = @net.query_variable(:rain)
    assert_in_delta(probs[:true], 0.5, 0.1)
    assert_in_delta(probs[:false], 0.5, 0.1)
  end

  def test_inference_on_grasswet_without_evidence_querying_grasswet
    @evidence = {}
    @net.set_evidence @evidence
    probs = @net.query_variable(:grass_wet)
    assert_in_delta(probs[:true], 0.6471, 0.1)
    assert_in_delta(probs[:false], 0.3529, 0.1)
  end
  
  def test_import_export
    output = @net.to_xmlbif
    newnet = Sbn::Net.from_xmlbif(output)
    assert_equal @net, newnet
    
    # test other network types
    raise NotImplementedError, 'Need to write more tests for import/export'
  end
  
  def test_equality
    raise NotImplementedError, 'Need to write test_equality'
  end
  
  def test_add_variable
    raise NotImplementedError, 'Need to write test_add_variable'
  end
  
  def test_query_variable
    raise NotImplementedError, 'Need to write test_query_variable'
  end
  
  def test_set_evidence
    raise NotImplementedError, 'Need to write test_set_evidence'
  end
  
  def test_symbolize_evidence
    raise NotImplementedError, 'Need to write test_symbolize_evidence'
  end
end