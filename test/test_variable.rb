require 'test/unit'
require File.dirname(__FILE__) + '/../lib/sbn'

class TestVariable < Test::Unit::TestCase # :nodoc:
  def setup
    @net = Sbn::Net.new
    @var1 = Sbn::Variable.new(@net, "var1")
    @var2 = Sbn::Variable.new(@net, "var2")
  end

  def test_add_child
    assert !@var1.children.include?(@var2)
    @var1.add_child(@var2)
    assert @var1.children.include?(@var2)
  end

  def test_add_child_no_recurse
    # variable shouldn't be able to add itself as a child
    children_before = @var1.children.dup
    @var1.add_child_no_recurse(@var1)
    children_after = @var1.children.dup
    assert_equal children_before, children_after
    
    # add child normally
    children_before = @var1.children.dup
    @var1.add_child_no_recurse(@var2)
    children_after = @var1.children.dup
    assert_not_equal children_before, children_after
    assert children_after.include?(@var2)

    # variable shouldn't be able to add same child twice
    children_before = @var1.children.dup
    @var1.add_child_no_recurse(@var2)
    children_after = @var1.children.dup
    assert_equal children_before, children_after
  end

  def test_add_parent
    assert !@var1.parents.include?(@var2)
    @var1.add_parent(@var2)
    assert @var1.parents.include?(@var2)
  end

  def test_add_parent_no_recurse
    # variable shouldn't be able to add itself as a parent
    parents_before = @var1.parents.dup
    @var1.add_parent_no_recurse(@var1)
    parents_after = @var1.parents.dup
    assert_equal parents_before, parents_after
    
    # add parent normally
    parents_before = @var1.parents.dup
    @var1.add_parent_no_recurse(@var2)
    parents_after = @var1.parents.dup
    assert_not_equal parents_before, parents_after
    assert parents_after.include?(@var2)

    # variable shouldn't be able to add same parent twice
    parents_before = @var1.parents.dup
    @var1.add_parent_no_recurse(@var2)
    parents_after = @var1.parents.dup
    assert_equal parents_before, parents_after
  end
  
  def test_to_s
    assert_equal "#{@var1.name}", "#{@var1}"
  end
  
  def test_equality
    assert_equal(@var1, @var1.dup)
  end
  
  def test_can_be_evaluated_eh
    @var1.add_child(@var2)
    assert @var1.can_be_evaluated?({})
    assert !@var2.can_be_evaluated?({})
  end

  def test_children
    assert @var1.children.class == Array and @var1.children.empty?
  end

  def test_evaluate_marginal
    assert_equal @var1.evaluate_marginal(:true, {}), 0.5
    assert_equal @var1.evaluate_marginal(:false, {}), 0.5
    
    @var1.add_child(@var2)
    @var2.set_probabilities([0.25, 0.75, 0.2, 0.8])
    assert_equal @var2.evaluate_marginal(:true, {:var1 => :true}), 0.25
    assert_equal @var2.evaluate_marginal(:false, {:var1 => :true}), 0.75
    assert_equal @var2.evaluate_marginal(:true, {:var1 => :false}), 0.2
    assert_equal @var2.evaluate_marginal(:false, {:var1 => :false}), 0.8
  end

  def test_evidence_name
    assert_equal @var1.evidence_name, @var1.name
  end

  def test_generate_probability_table
    test_probability_table
  end

  def test_get_observed_state
    evidence = {:var1 => :true}
    assert_equal evidence[@var1.name], @var1.get_observed_state(evidence)
  end

  def test_get_random_state
    states = [:good, :bad, :ugly]
    n = Sbn::Variable.new(@net, :george, [0.25, 0.25, 0.5], states)
    evidence = {}
    assert states.include?(n.get_random_state(evidence))
    assert states.include?(n.get_random_state_with_markov_blanket(evidence))
  end

  def test_parents
    assert @var1.parents.class == Array and @var1.parents.empty?
  end

  def test_probability_table
    @var1.add_child(@var2)
    
    # number of probabilities no longer matches number of states because
    # var2 now has a parent.
    assert_nil @var2.probability_table
    
    @var2.set_probabilities([0.25, 0.75, 0.2, 0.8])
    assert_not_nil @var2.probability_table
    
    expected_table = [[[:true, :true], 0.25],
                      [[:true, :false], 0.75],
                      [[:false, :true], 0.2],
                      [[:false, :false], 0.8]]
    assert_equal @var2.probability_table, expected_table
  end

  def test_set_in_evidence_eh
    evidence = {:var1 => :true, :var2 => :false}
    assert @var1.set_in_evidence?(evidence)
    assert @var2.set_in_evidence?(evidence)
  end

  def test_set_probabilities
    @var1.add_child(@var2)
    probs = @var2.instance_variable_get('@probabilities')
    new_probs = [0.25, 0.75, 0.2, 0.8]
    assert_not_equal probs, new_probs
  
    @var2.set_probabilities(new_probs)
    probs = @var2.instance_variable_get('@probabilities')
    assert_not_nil probs, new_probs
  end

  def test_set_probability
    @var1.add_child(@var2)
    @var2.set_probability(0.75, {:var1 => :false, :var2 => :false})
    probs = @var2.instance_variable_get('@probabilities')
    assert_equal probs[3], 0.75
  end

  def test_set_states
    var = Sbn::Variable.new(@net, :var3, [], [])
    assert var.states.empty?
    var.set_states([:true, :false])
    assert !var.states.empty?
    assert_equal var.states, [:true, :false]
  end

  def test_states
    var = Sbn::Variable.new(@net, :var3, [], [])
    assert_not_nil var.states
    assert_equal var.states, []
  end

  def test_to_xmlbif_definition
    xml = Builder::XmlMarkup.new(:indent => 2)
    expected_output = <<-EOS
    <definition>
      <for>var1</for>
      <table>0.5 0.5</table>
    </definition>    
    EOS
    assert_equal @var1.to_xmlbif_definition(xml).gsub(/\s+/, ''), expected_output.gsub(/\s+/, '')
  end

  def test_to_xmlbif_variable
    xml = Builder::XmlMarkup.new(:indent => 2)
    expected_output = <<-EOS
    <variable type="nature">
      <name>var1</name>
      <outcome>true</outcome>
      <outcome>false</outcome>
      <property>SbnVariableType = Sbn::Variable</property>
    </variable>
    EOS
    assert_equal @var1.to_xmlbif_variable(xml).gsub(/\s+/, ''), expected_output.gsub(/\s+/, '')
  end
end

class TestNumericVariable < Test::Unit::TestCase # :nodoc:
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

class TestStringVariable < Test::Unit::TestCase # :nodoc:
  def setup
    @net = Sbn::Net.new("Categorization")
    @category = Sbn::Variable.new(@net, :category, [0.33, 0.33, 0.33], [:food, :groceries, :gas])
    @text = Sbn::StringVariable.new(@net, :text)
    @category.add_child(@text)
    @net.learn([
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
    @covars = @text.covariables
  end
  
  def test_covar_evidence_name
    @covars.each do |covar|
      manager_name = covar.instance_variable_get('@manager_name')
      assert_equal @text.name, manager_name
    end
  end

  def test_covar_get_observed_state
    evidence = {:text => "groceries"}
    @covars.each do |covar|
      manager_name = covar.instance_variable_get('@manager_name')
      text_to_match = covar.instance_variable_get('@text_to_match')
      assert_equal covar.get_observed_state(evidence), (evidence[manager_name].include?(text_to_match) ? :true : :false)
    end
  end

  def test_covar_to_xmlbif_variable
    xml = Builder::XmlMarkup.new(:indent => 2)
    expected_output = <<-EOS
    <variable type="nature">
      <name>text_covar_foo</name>
      <outcome>true</outcome>
      <outcome>false</outcome>
      <property>SbnVariableType = Sbn::StringCovariable</property>
      <property>ManagerVariableName = text</property>
      <property>TextToMatch = "foo"</property>
    </variable>
    EOS
    assert @covars.first.to_xmlbif_variable(xml).gsub(/\s+/, ''), expected_output.gsub(/\s+/, '') 
  end

  def test_add_child_no_recurse
    covariable_children = @text.instance_variable_get('@covariable_children')
    newvar = Sbn::Variable.new(@net, :newvar)
    assert !covariable_children.include?(newvar)
    @text.add_child(newvar)
    covariable_children = @text.instance_variable_get('@covariable_children')
    assert covariable_children.include?(newvar)
  end

  def test_add_covariable
    covar = Sbn::StringCovariable.new(@net, :text, 'something', [0.5, 0.5])
    assert !@text.covariables.include?(covar)
    @text.add_covariable(covar)
    assert @text.covariables.include?(covar)
  end

  def test_add_parent_no_recurse
    covariable_parents = @text.instance_variable_get('@covariable_parents')
    newvar = Sbn::Variable.new(@net, :newvar)
    assert !covariable_parents.include?(newvar)
    @text.add_parent(newvar)
    covariable_parents = @text.instance_variable_get('@covariable_parents')
    assert covariable_parents.include?(newvar)
  end

  def test_add_sample_point
    # make sure covariables are created with each sample point
    newtext = "newtext"
    assert_equal 3, @text.covariables.size
    @text.add_sample_point({:text => newtext, :category => :gas})
    ngrams = []
    Sbn::StringVariable::DEFAULT_NGRAM_SIZES.each {|len| ngrams.concat(newtext.ngrams(len)) }
    assert_equal 3 + ngrams.size, @text.covariables.size
  end

  def test_covariables
    assert_not_nil @text.covariables
  end

  def test_set_in_evidence_eh
    # assert_raise(RuntimeError) { @text.set_in_evidence?({:text => "newtext", :category => :gas}) } 
    assert @text.set_in_evidence?({:text => "newtext", :category => :gas})
  end

  def test_to_xmlbif_definition
    xml = Builder::XmlMarkup.new(:indent => 2)
    assert_nil @text.to_xmlbif_definition(xml)
  end

  def test_to_xmlbif_variable
    xml = Builder::XmlMarkup.new(:indent => 2)
    expected_output = <<-EOS
    <variable type="nature">
      <name>text</name>
      <property>SbnVariableType = Sbn::StringVariable</property>
      <property>Covariables = foo,gas,gro</property>
      <property>Parents = category</property>
    </variable>
    EOS
    assert_equal expected_output.gsub(/\s+/, ''), @text.to_xmlbif_variable(xml).gsub(/\s+/, '')
  end
  
  def test_is_complete_evidence_eh
    evidence = {}
    assert !@text.is_complete_evidence?(evidence)    
    evidence = {:category => :food, :text => "foo"}
    assert @text.is_complete_evidence?(evidence)
  end
end