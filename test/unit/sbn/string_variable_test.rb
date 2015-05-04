class StringVariableTest < Minitest::Test # :nodoc:

  def setup
    @net = Sbn::Net.new("Categorization")
    @category = Sbn::Variable.new(@net, :category, [0.33, 0.33, 0.33], [:food, :groceries, :gas])
    @text = Sbn::StringVariable.new(@net, :text)
    @category.add_child(@text)
    @net.learn([
      {category: :food, text: 'foo'},
      {category: :food, text: 'gro'},
      {category: :food, text: 'foo'},
      {category: :food, text: 'foo'},
      {category: :groceries, text: 'gro'},
      {category: :groceries, text: 'gro'},
      {category: :groceries, text: 'foo'},
      {category: :groceries, text: 'gro'},
      {category: :gas, text: 'gas'},
      {category: :gas, text: 'gas'},
      {category: :gas, text: 'gas'},
      {category: :gas, text: 'gas'}
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
    evidence = {text: "groceries"}
    @covars.each do |covar|
      manager_name = covar.instance_variable_get('@manager_name')
      text_to_match = covar.instance_variable_get('@text_to_match')
      assert_equal covar.get_observed_state(evidence), (evidence[manager_name].include?(text_to_match) ? :true : :false)
    end
  end

  def test_covar_to_xmlbif_variable
    xml = Builder::XmlMarkup.new(indent: 2)
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
    @text.add_sample_point({text: newtext, category: :gas})
    ngrams = []
    Sbn::StringVariable::DEFAULT_NGRAM_SIZES.each {|len| ngrams.concat(newtext.ngrams(len)) }
    assert_equal 3 + ngrams.size, @text.covariables.size
  end

  def test_covariables
    refute_nil @text.covariables
  end

  def test_set_in_evidence_eh
    # assert_raise(RuntimeError) { @text.set_in_evidence?({text: "newtext", category: :gas}) } 
    assert @text.set_in_evidence?({text: "newtext", category: :gas})
  end

  def test_to_xmlbif_definition
    xml = Builder::XmlMarkup.new(indent: 2)
    assert_nil @text.to_xmlbif_definition(xml)
  end

  def test_to_xmlbif_variable
    xml = Builder::XmlMarkup.new(indent: 2)
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
    evidence = {category: :food, text: "foo"}
    assert @text.is_complete_evidence?(evidence)
  end
end