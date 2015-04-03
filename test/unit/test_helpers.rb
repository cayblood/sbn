require 'test_helper'

class EnumsTester
  enums %w(FOO BAR BAZ)
  bitwise_enums %w(ONE TWO FOUR EIGHT)  
end

class TestHelpers < Minitest::Test # :nodoc:
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
    assert_equal EnumsTester::FOO, 0
    assert_equal EnumsTester::BAR, 1
    assert_equal EnumsTester::BAZ, 2
    assert_equal EnumsTester::ONE, 1
    assert_equal EnumsTester::TWO, 2
    assert_equal EnumsTester::FOUR, 4
    assert_equal EnumsTester::EIGHT, 8
  end
  
  def test_to_underscore_sym
    assert_equal 'THIS IS AN UGLY STRING'.to_underscore_sym, :this_is_an_ugly_string
    assert_equal 'this is an ugly string'.to_underscore_sym, :this_is_an_ugly_string
    assert_equal :"this is an ugly string".to_underscore_sym, :this_is_an_ugly_string
    assert_equal :"THIS IS AN UGLY STRING".to_underscore_sym, :this_is_an_ugly_string
  end
  
  def test_symbolize_values
    refute_equal %w(one two three), [:one, :two, :three]
    assert_equal %w(one two three).symbolize_values, [:one, :two, :three]
    arr = %w(one two three)
    arr.symbolize_values!
    assert_equal arr, [:one, :two, :three]
  end
  
  def test_symbolize_keys_and_values
    refute_equal({"one" => "two", "three" => "four"}, {:one => :two, :three => :four})
    assert_equal({"one" => "two", "three" => "four"}.symbolize_keys_and_values, {:one => :two, :three => :four})
    h = {"one" => "two", "three" => "four"}
    h.symbolize_keys_and_values!
    assert_equal(h, {:one => :two, :three => :four})
  end
  
  def test_normalize
    assert_equal [0.1, 0.1].normalize, [0.5, 0.5]
    assert_equal [2, 2, 4].normalize, [0.25, 0.25, 0.5]
    assert_equal [1, 1, 1, 1, 1].normalize, [0.2, 0.2, 0.2, 0.2, 0.2]
    arr = [1, 1, 1, 1, 1]
    arr.normalize!
    assert_equal arr, [0.2, 0.2, 0.2, 0.2, 0.2]
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