class Sbn
  enums %w(INFERENCE_MODE_VARIABLE_ELIMINATION,
           INFERENCE_MODE_MARKOV_CHAIN_MONTE_CARLO)
  
  MCMC_NUM_SAMPLES = 2000
  
  class Net
    attr_reader :name, :variables
    
    def initialize(name = '')
      @@net_count ||= 0
      @@net_count += 1
      @name = (name.empty? ? "net_#{@@net_count}" : name.to_underscore_sym)
      @variables = {}
      @evidence = {}
    end
    
    def add_variable(variable)
      if @variables.has_key? variable.name
        raise "Variable of same name has already been added to this net"
      end
      @variables[variable.name] = variable
    end
    
    def ==(net)
      returnval = true
      returnval = false unless net.name == @name
      unless @variables.keys.map {|k| k.to_s}.sort == net.variables.keys.map {|k| k.to_s}.sort
        returnval = false
      end
      net.variables.each do |name, variable|
        if @variables.has_key? name
          parent_names = []
          variable.parents.each {|p| parent_names << p.name.to_s }
          my_parent_names = []
          @variables[name].parents.each {|p| my_parent_names << p.name.to_s }
          returnval = false unless parent_names.sort == my_parent_names.sort
          table = variable.probability_table.transpose.last
          my_table = @variables[name].probability_table.transpose.last
          returnval = false unless table == my_table          
        else
          returnval = false
        end
      end
      returnval
    end
    
    def <<(obj)
      if obj.is_a? Array
        obj.each {|n| add_variable(n) }
      else
        add_variable(obj)
      end
    end
    
    def symbolize_evidence(evidence)
      newevidence = {}
      evidence.each do |key, val|
        key = key.to_sym
        if @variables[key].is_a?(StringVariable)
          newevidence[key] = val.downcase
        elsif @variables[key].is_a?(NumericVariable)
          newevidence[key] = val.to_f          
        else
          newevidence[key] = val.to_sym
        end
      end
      newevidence
    end
    
    def set_evidence(event)
      @evidence = symbolize_evidence(event)
    end
  end
end
