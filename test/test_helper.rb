require 'test/unit'
require File.dirname(__FILE__) + '/../lib/sbn4r'

class TestHelper < Test::Unit::TestCase
  def test_ngrams
    assert_equal "THIS IS A STRING".ngrams(2), ["TH", "HI", "IS", "S ", " I", "IS", "S ", " A", "A ", " S", "ST", "TR", "RI", "IN", "NG"]
    assert_equal "THIS IS A STRING".ngrams(3), ["THI", "HIS", "IS ", "S I", " IS", "IS ", "S A", " A ", "A S", " ST", "STR", "TRI", "RIN", "ING"]
    assert_equal "THIS IS A STRING".ngrams(4), ["THIS", "HIS ", "IS I", "S IS", " IS ", "IS A", "S A ", " A S", "A ST", " STR", "STRI", "TRIN", "RING"]
    assert_equal "THIS IS A STRING".ngrams(5), ["THIS ", "HIS I", "IS IS", "S IS ", " IS A", "IS A ", "S A S", " A ST", "A STR", " STRI", "STRIN", "TRING"]
  end
end