require 'test_helper'

class NetTest < Minitest::Test # :nodoc:
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
  
  def generate_simple_network
    net = Sbn::Net.new("Test")
    var1 = Sbn::Variable.new(net, :var1)
    var2 = Sbn::Variable.new(net, :var2, [0.25, 0.75, 0.75, 0.25])
    var2.add_parent(var1)
    net
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
    @net.set_evidence({})
    probs = @net.query_variable(:cloudy)
    assert_in_delta(probs[:true], 0.5, 0.1)
    assert_in_delta(probs[:false], 0.5, 0.1)
  end

  def test_inference_on_grasswet_without_evidence_querying_sprinkler
    @net.set_evidence({})
    probs = @net.query_variable(:sprinkler)
    assert_in_delta(probs[:true], 0.3, 0.1)
    assert_in_delta(probs[:false], 0.7, 0.1)
  end

  def test_inference_on_grasswet_without_evidence_querying_rain
    @net.set_evidence({})
    probs = @net.query_variable(:rain)
    assert_in_delta(probs[:true], 0.5, 0.1)
    assert_in_delta(probs[:false], 0.5, 0.1)
  end

  def test_inference_on_grasswet_without_evidence_querying_grasswet
    @net.set_evidence({})
    probs = @net.query_variable(:grass_wet)
    assert_in_delta(probs[:true], 0.6471, 0.1)
    assert_in_delta(probs[:false], 0.3529, 0.1)
  end
  
  def test_import_export
    output = @net.to_xmlbif
    newnet = Sbn::Net.from_xmlbif(output)
    assert_equal @net, newnet
  end
  
  def test_equality
    net1 = generate_simple_network
    net2 = generate_simple_network
    net3 = Sbn::Net.new('Another Net')
    assert_equal net1, net2
    refute_equal net1, net3
  end
  
  def test_add_variable
    net = generate_simple_network
    assert net.instance_variable_get('@variables').has_key?(:var1)
    assert net.instance_variable_get('@variables').has_key?(:var2)
  end
  
  def test_query_variable
    net = generate_simple_network
    net.set_evidence :var1 => :true
    probs = net.query_variable(:var2)
    assert probs.has_key?(:true)
    assert probs.has_key?(:false)
    assert_in_delta(probs[:true], 0.25, 0.1)
    assert_in_delta(probs[:false], 0.75, 0.1)
  end
  
  def test_set_evidence
    net = generate_simple_network
    net.set_evidence 'var2' => :false
    variables = net.instance_variable_get('@variables')
    evidence = net.instance_variable_get('@evidence')
    assert variables[:var2].set_in_evidence?(evidence)
    assert !variables[:var1].set_in_evidence?(evidence)
  end
  
  def test_evidence_transformation
    # Create a network with each kind of variable and make sure evidence
    # transformation works.
    net = Sbn::Net.new("Test")
    Sbn::Variable.new(net, :basic_var)
    string_var = Sbn::StringVariable.new(net, :string_var)
    num_var = Sbn::NumericVariable.new(net, :num_var, [0.5, 0.5], [1.0])
    string_var.add_sample_point({:basic_var => :true, :string_var => "test", :num_var => 1.5})
    
    # should not be able to set covariables directly
    assert_raises(RuntimeError) { net.set_evidence({:string_var_covar_1 => :true}) }
    
    net.set_evidence 'BASIC VAR' => 'true', 'string_var' => "TesT", 'num_var' => 3
    evidence = net.instance_variable_get('@evidence')
    assert evidence.has_key?(:basic_var)
    assert !evidence.has_key?('BASIC VAR')
    assert evidence[:basic_var].is_a?(Symbol)
    assert_equal evidence[:basic_var], :true
    
    assert evidence.has_key?(:string_var)
    assert !evidence.has_key?('string_var')
    assert evidence[:string_var].is_a?(String)
    assert_equal evidence[:string_var], evidence[:string_var].downcase
    
    assert evidence.has_key?(:num_var)
    assert !evidence.has_key?('num_var')
    assert evidence[:num_var].is_a?(Float)
    assert_equal evidence[:num_var], 3.0
  end
end
