class Sbn
  class Node
    attr_accessor :name, :states
    
    def initialize(name = '', states = [], probabilities = [])
      @name = name.to_sym
      @children = []
      @parents = []
      @states = []
      set_states(states)
      set_probabilities(probabilities)
    end
    
    def to_s
      @name.to_s
    end
    
    def add_child(node)
      return if node == self
      @children << node
      node.add_parent(self)
    end
    
    def add_parent(node)
      return if node == self
      @parents << node
      node.add_child(self)
    end
    
    def set_states(states)
      states.symbolize_values!
      @states = states
      generate_state_table
    end
    
    def set_probability(probability, event)
      event.symbolize_keys_and_values!
      c = [event[@name]]
      index = state_combinations.index(c)
      @probabilities[index] = probability
      generate_state_table
    end
    
    def set_probabilities(probs)
      @probabilities = probs
      generate_state_table
    end

  	# A node can't be evaluated unless its parent nodes have
  	# been observed    
    def can_be_evaluated?(evidence)
      returnval = true
      parents.each {|p| returnval = false unless evidence.has_key?(p.name) }
      returnval
    end
    
  	# In order to draw uniformly from the probabilty space, we can't
  	# just pick a random state.  Instead we generate a random number
  	# between zero and one and iterate through the states until the 
  	# cumulative sum of their probabilities exceeds our random number.    
    def get_random_state(event = {})
      event.symbolize_keys_and_values!
      sum = 0.0
      num = rand
      returnval = nil
      @states.each do |s|
        returnval = s
        r = evaluate_marginal(s, event)
        sum += r
        break if num < sum
      end
      returnval      
    end
    
    def get_random_state_with_markov_blanket(event)
      
    end
    
  private
    def state_combinations
      all_states = [@states]
      @parents.each do |p|
        c << event[p.name]
        all_states << p.states
      end
      Combination.new(all_states).to_a
    end
  
    def generate_state_table
      return unless @probabilities
      probs = @probabilities.dup
      @state_table = state_combinations.collect {|e| [e, probs.shift] }
    end
  
    def remove_irrelevant_states(probabilities, state, evidence)
      probabilities.reject! {|element| element.first.first != state }
      index = 1
      @parents.each do |node|
        raise "Marginal cannot be evaluated because not all parent nodes are set" unless evidence.has_key?(node.name)
        probabilities.reject! {|element| element.first[index] != evidence[node.name] }
        index += 1
      end
      probabilities
    end
    
    def evaluate_marginal(state, event)
      temp_probs = @state_table.dup
      remove_irrelevant_states(temp_probs, state, event)
      sum = 0.0
      temp_probs.each {|e| sum += e[1] }
      sum
    end
    
    def evaluate_markov_blanket(state, event)
      
    end
  end
end