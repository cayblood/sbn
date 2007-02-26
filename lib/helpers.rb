# used for defining enumerated constants
class Object
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

class String
  def to_underscore_sym
    self.titleize.gsub(/\s+/, '').underscore.to_sym
  end

  def ngrams(len = 1)
    ngrams = []
    (0..size - len).each do |n|
      ng = self[n...(n + len)]
      ngrams.push(ng)
      yield ng if block_given?
    end
    ngrams
  end
end

class Symbol
  def to_underscore_sym
    self.to_s.titleize.gsub(/\s+/, '').underscore.to_sym
  end
end

class Array
  def symbolize_values
    self.map {|e| e.to_underscore_sym }
  end
  
  def symbolize_values!
    self.map! {|e| e.to_underscore_sym }
  end
  
  def normalize
    sum = self.inject(0.0) {|sum, e| sum += e }
    self.map {|e| e.to_f / sum }
  end
  
  def normalize!
    sum = self.inject(0.0) {|sum, e| sum += e }
    self.map! {|e| e.to_f / sum }
  end
end

class Hash
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

module Enumerable
  ##
  # Sum of all the elements of the Enumerable
  def sum
    return self.inject(0) { |acc, i| acc + i }
  end

  ##
  # Average of all the elements of the Enumerable
  #
  # The Enumerable must respond to #length
  def average
    return self.sum / self.length.to_f
  end

  ##
  # Sample variance of all the elements of the Enumerable
  #
  # The Enumerable must respond to #length
  def sample_variance
    avg = self.average
    sum = self.inject(0) { |acc, i| acc + (i - avg) ** 2 }
    return (1 / self.length.to_f * sum)
  end

  ##
  # Standard deviation of all the elements of the Enumerable
  #
  # The Enumerable must respond to #length
  def standard_deviation
    return Math.sqrt(self.sample_variance)
  end
end