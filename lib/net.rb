class Sbn
  class Net
    attr_reader :name, :variables
    
    def initialize(name = '')
      @@net_count ||= 0
      @@net_count += 1
      @name = (name.empty? ? "net_#{@@net_count}" : name.to_underscore_sym)
      @variables = {}
      @evidence = {}
    end

    def ==(obj); test_equal(obj); end
    def eql?(obj); test_equal(obj); end
    def ===(obj); test_equal(obj); end
  
    def add_variable(variable)
      name = variable.name
      if @variables.has_key? name
        raise "Variable of same name has already been added to this net"
      end
      @variables[name] = variable
    end
    
    def symbolize_evidence(evidence)
      newevidence = {}
      evidence.each do |key, val|
        key = key.to_sym
        newevidence[key] = @variables[key].transform_evidence_value(val)
      end
      newevidence
    end
    
    def set_evidence(event)
      @evidence = symbolize_evidence(event)
    end

  private
    def test_equal(net)
      returnval = true
      returnval = false unless net.class == self.class and self.class == Net
      returnval = false unless net.name == @name
      returnval = false unless @variables.keys.map {|k| k.to_s}.sort == net.variables.keys.map {|k| k.to_s}.sort
      net.variables.each {|name, variable| returnval = false unless variable == @variables[name] }
      returnval
    end
  end
end
