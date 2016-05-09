# = helpers.rb: Helper methods added to existing Ruby classes
# Credit goes to ruby-talk posts for many of these (details below).
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

require 'active_support/inflector'

# Thanks to Brian Schrer <ruby.brian _at_ gmail.com> for the
# following two methods, from ruby-talk post #150456.
class Object # :nodoc:
  def self.enums(*args)    
    args.flatten.each_with_index do |const, i|
      class_eval %(#{const} = #{i})
    end
  end
  
  def self.bitwise_enums(*args)    
    args.flatten.each_with_index do |const, i|
      class_eval %(#{const} = #{2**i})
    end
  end
end

class String # :nodoc:
  def to_underscore_sym
    self.titleize.gsub(/\s+/, '').underscore.to_sym
  end

  # Thanks to David Alan Black for this method, from
  # ruby-talk post #11792
  def ngrams(len = 1)
    ngrams = []
    len = size if len > size
    (0..size - len).each do |n|
      ng = self[n...(n + len)]
      ngrams.push(ng)
      yield ng if block_given?
    end
    ngrams
  end
end

class Symbol # :nodoc:
  def to_underscore_sym
    self.to_s.titleize.gsub(/\s+/, '').underscore.to_sym
  end
end

class Array # :nodoc:
  def symbolize_values
    self.map {|e| e.to_underscore_sym }
  end
  
  def symbolize_values!
    self.map! {|e| e.to_underscore_sym }
  end
  
  def normalize
    sum = self.inject(0.0) {|s, e| s += e }
    self.map {|e| e.to_f / sum }
  end
  
  def normalize!
    sum = self.inject(0.0) {|s, e| s += e }
    self.map! {|e| e.to_f / sum }
  end
end

class Hash # :nodoc:
  def symbolize_keys_and_values
    inject({}) do |options, (key, value)|
      key = key.to_underscore_sym
      value = value.to_underscore_sym
      options[key] = value
      options
    end
  end
  
  def symbolize_keys_and_values!
    keys.each do |key|
      newkey = key.to_underscore_sym
      self[newkey] = self[key].to_underscore_sym
      delete(key) unless key == newkey
    end
    self
  end
end

# Thanks to Eric Hodel for the following additions
# to the enumerable model, from ruby-talk post #135920.
module Enumerable # :nodoc:
  ##
  # Sum of all the elements of the Enumerable
  def sum
    self.inject(0) { |acc, i| acc + i }
  end

  ##
  # Average of all the elements of the Enumerable
  #
  # The Enumerable must respond to #length
  def average
    self.sum / self.length.to_f
  end

  ##
  # Sample variance of all the elements of the Enumerable
  #
  # The Enumerable must respond to #length
  def sample_variance
    avg = self.average
    sum = self.inject(0) { |acc, i| acc + (i - avg) ** 2 }
    1 / self.length.to_f * sum
  end

  ##
  # Standard deviation of all the elements of the Enumerable
  #
  # The Enumerable must respond to #length
  def standard_deviation
    Math.sqrt(self.sample_variance)
  end
end
