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

class Array
  def symbolize_values
    self.map {|e| e.to_sym }
  end
  
  def symbolize_values!
    self.map! {|e| e.to_sym }
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
      options[key.to_sym] = value.to_sym
      options
    end
  end
  
  def symbolize_keys_and_values!
    keys.each do |key|
      self[key.to_sym] = self[key].to_sym
      delete(key) unless key.is_a?(Symbol)
    end
    self
  end
end