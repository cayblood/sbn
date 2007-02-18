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
      @variables[variable.name] = variable
    end
    
    def ==(net)
      returnval = true
      returnval = false unless net.name == @name
      returnval = false unless @variables.keys.map {|k| k.to_s}.sort == net.variables.keys.map {|k| k.to_s}.sort
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
    
    def set_evidence(event)
      @evidence = event.symbolize_keys_and_values
    end
  end
end
