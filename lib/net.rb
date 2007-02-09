class Sbn
  enums %w(INFERENCE_MODE_VARIABLE_ELIMINATION,
           INFERENCE_MODE_MARKOV_CHAIN_MONTE_CARLO)
  
  MCMC_NUM_SAMPLES = 2000
  
  class Net
    attr_reader :name, :nodes
    
    def initialize(name = '')
      @@net_count ||= 0
      @@net_count += 1
      @name = (name.empty? ? "net_#{@@net_count}" : name.to_underscore_sym)
      @nodes = {}
      @evidence = {}
    end
    
    def add_node(node)
      @nodes[node.name] = node
    end
    
    def ==(net)
      returnval = true
      returnval = false unless net.name == @name
      returnval = false unless @nodes.keys.map {|k| k.to_s}.sort == net.nodes.keys.map {|k| k.to_s}.sort
      net.nodes.each do |name, node|
        if @nodes.has_key? name
          parent_names = []
          node.parents.each {|p| parent_names << p.name.to_s }
          my_parent_names = []
          @nodes[name].parents.each {|p| my_parent_names << p.name.to_s }
          returnval = false unless parent_names.sort == my_parent_names.sort
          table = node.probability_table.transpose.last
          my_table = @nodes[name].probability_table.transpose.last
          returnval = false unless table == my_table          
        else
          returnval = false
        end
      end
      returnval
    end
    
    def <<(obj)
      if obj.is_a? Array
        obj.each {|n| add_node(n) }
      else
        add_node(obj)
      end
    end
    
    def set_evidence(event)
      @evidence = event.symbolize_keys_and_values
    end
  end
end
