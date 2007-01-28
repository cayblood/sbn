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