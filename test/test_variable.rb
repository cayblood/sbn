require 'test/unit' unless defined? $ZENTEST and $ZENTEST
require File.dirname(__FILE__) + '/../lib/sbn4r'

class TestVariable < Test::Unit::TestCase # :nodoc:
  def setup
    @net = Sbn::Net.new
  end
  
  def teardown
  end

  def test_add_child
    raise NotImplementedError, 'Need to write test_add_child'
  end

  def test_add_child_no_recurse
    raise NotImplementedError, 'Need to write test_add_child_no_recurse'
  end

  def test_add_parent
    raise NotImplementedError, 'Need to write test_add_parent'
  end

  def test_add_parent_no_recurse
    raise NotImplementedError, 'Need to write test_add_parent_no_recurse'
  end

  def test_can_be_evaluated_eh
    raise NotImplementedError, 'Need to write test_can_be_evaluated_eh'
  end

  def test_children
    raise NotImplementedError, 'Need to write test_children'
  end

  def test_evaluate_marginal
    raise NotImplementedError, 'Need to write test_evaluate_marginal'
  end

  def test_evidence_name
    raise NotImplementedError, 'Need to write test_evidence_name'
  end

  def test_generate_probability_table
    raise NotImplementedError, 'Need to write test_generate_probability_table'
  end

  def test_get_observed_state
    raise NotImplementedError, 'Need to write test_get_observed_state'
  end

  def test_get_random_state
    n = Sbn::Variable.new(@net, 'george', [0.25, 0.25, 0.5], ['good', 'bad', 'ugly'])
    raise NotImplementedError, 'Need to write test_get_random_state'
  end

  def test_get_random_state_with_markov_blanket
    raise NotImplementedError, 'Need to write test_get_random_state_with_markov_blanket'
  end

  def test_parents
    raise NotImplementedError, 'Need to write test_parents'
  end

  def test_probability_table
    raise NotImplementedError, 'Need to write test_probability_table'
  end

  def test_set_in_evidence_eh
    raise NotImplementedError, 'Need to write test_set_in_evidence_eh'
  end

  def test_set_probabilities
    raise NotImplementedError, 'Need to write test_set_probabilities'
  end

  def test_set_probability
    raise NotImplementedError, 'Need to write test_set_probability'
  end

  def test_set_states
    raise NotImplementedError, 'Need to write test_set_states'
  end

  def test_states
    raise NotImplementedError, 'Need to write test_states'
  end

  def test_to_xmlbif_definition
    raise NotImplementedError, 'Need to write test_to_xmlbif_definition'
  end

  def test_to_xmlbif_variable
    raise NotImplementedError, 'Need to write test_to_xmlbif_variable'
  end
end

class TestNumericVariable < Test::Unit::TestCase # :nodoc:
  def test_get_observed_state
    raise NotImplementedError, 'Need to write test_get_observed_state'
  end

  def test_set_probabilities_from_training_data
    raise NotImplementedError, 'Need to write test_set_probabilities_from_training_data'
  end

  def test_state_thresholds
    raise NotImplementedError, 'Need to write test_state_thresholds'
  end

  def test_to_xmlbif_variable
    raise NotImplementedError, 'Need to write test_to_xmlbif_variable'
  end
end

class TestStringCovariable < Test::Unit::TestCase # :nodoc:
  def test_evidence_name
    raise NotImplementedError, 'Need to write test_evidence_name'
  end

  def test_get_observed_state
    raise NotImplementedError, 'Need to write test_get_observed_state'
  end

  def test_to_xmlbif_variable
    raise NotImplementedError, 'Need to write test_to_xmlbif_variable'
  end
end

class TestStringVariable < Test::Unit::TestCase # :nodoc:
  def test_add_child
    raise NotImplementedError, 'Need to write test_add_child'
  end

  def test_add_child_no_recurse
    raise NotImplementedError, 'Need to write test_add_child_no_recurse'
  end

  def test_add_covariable
    raise NotImplementedError, 'Need to write test_add_covariable'
  end

  def test_add_parent
    raise NotImplementedError, 'Need to write test_add_parent'
  end

  def test_add_parent_no_recurse
    raise NotImplementedError, 'Need to write test_add_parent_no_recurse'
  end

  def test_add_training_set
    raise NotImplementedError, 'Need to write test_add_training_set'
  end

  def test_covariables
    raise NotImplementedError, 'Need to write test_covariables'
  end

  def test_generate_probability_table
    raise NotImplementedError, 'Need to write test_generate_probability_table'
  end

  def test_set_in_evidence_eh
    raise NotImplementedError, 'Need to write test_set_in_evidence_eh'
  end

  def test_to_xmlbif_definition
    raise NotImplementedError, 'Need to write test_to_xmlbif_definition'
  end

  def test_to_xmlbif_variable
    raise NotImplementedError, 'Need to write test_to_xmlbif_variable'
  end
end