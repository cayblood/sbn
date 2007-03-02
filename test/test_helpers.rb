require 'test/unit'
require File.dirname(__FILE__) + '/../lib/sbn4r'

class TestHelpers < Test::Unit::TestCase # :nodoc:

  # Tests for Enumerable helpers
  def test_sum
    assert_equal 45, (1..9).sum
  end

  def test_average
    # Ranges don't have a length
    assert_in_delta 5.0, (1..9).to_a.average, 0.01
  end

  def test_sample_variance
    assert_in_delta 6.6666, (1..9).to_a.sample_variance, 0.0001
  end

  def test_standard_deviation
    assert_in_delta 2.5819, (1..9).to_a.standard_deviation, 0.0001
  end
  
  def test_enums
    raise NotImplementedError, 'Need to write test_enums'
  end
  
  def test_to_underscore_sym
    # remember to test both strings and symbols
    raise NotImplementedError, 'Need to write test_to_underscore_sym'
  end
  
  def test_symbolize_values
    raise NotImplementedError, 'Need to write test_symbolize_values'
  end
  
  def test_symbolize_keys_and_values
    raise NotImplementedError, 'Need to write test_symbolize_keys_and_values'
  end
  
  def test_normalize
    raise NotImplementedError, 'Need to write test_normalize'
  end
  
  def test_ngrams
    two_ngram_array = ["TH", "HI", "IS", "S ", " I", "IS", "S ", " A", "A ", " S", "ST", "TR", "RI", "IN", "NG"]
    assert_equal "THIS IS A STRING".ngrams(2), two_ngram_array
    three_ngram_array = ["THI", "HIS", "IS ", "S I", " IS", "IS ", "S A", " A ", "A S", " ST", "STR", "TRI", "RIN", "ING"]
    assert_equal "THIS IS A STRING".ngrams(3), three_ngram_array
    four_ngram_array = ["THIS", "HIS ", "IS I", "S IS", " IS ", "IS A", "S A ", " A S", "A ST", " STR", "STRI", "TRIN", "RING"]
    assert_equal "THIS IS A STRING".ngrams(4), four_ngram_array
    five_ngram_array = ["THIS ", "HIS I", "IS IS", "S IS ", " IS A", "IS A ", "S A S", " A ST", "A STR", " STRI", "STRIN", "TRING"]
    assert_equal "THIS IS A STRING".ngrams(5), five_ngram_array
  end
end