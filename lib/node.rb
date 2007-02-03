class Sbn
  class Node
    attr_reader :name, :states, :parents, :children, :probability_table
    
    def initialize(name = '', states = [], probabilities = [])
      @name = name.to_underscore_sym
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
      node.parents << self
      node.generate_probability_table
    end
    
    def add_parent(node)
      return if node == self
      @parents << node
      node.children << self
      generate_probability_table
    end
    
    def set_states(states)
      states.symbolize_values!
      @states = states
      generate_probability_table
    end
    
    def set_probability(probability, event)
      event.symbolize_keys_and_values!
      c = [event[@name]]
      index = state_combinations.index(c)
      @probabilities[index] = probability
      generate_probability_table
    end
    
    def set_probabilities(probs)
      @probabilities = probs
      generate_probability_table
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
      seek_state {|s| evaluate_marginal(s, event) }
    end
    
  	# similar to get_random_state() except it evaluates a node's markov
  	# blanket in addition to the node itself.
    def get_random_state_with_markov_blanket(event)
      event.symbolize_keys_and_values!
      evaluations = []
      @states.each {|s| evaluations << evaluate_markov_blanket(s, event) }
      evaluations.normalize!
      seek_state {|s| evaluations.shift }
    end

    def generate_probability_table
      return unless @probabilities
      probs = @probabilities.dup
      @probability_table = state_combinations.collect {|e| [e, probs.shift] }
    end

    def evaluate_marginal(state, event)
      temp_probs = @probability_table.dup
      remove_irrelevant_states(temp_probs, state, event)
      sum = 0.0
      temp_probs.each {|e| sum += e[1] }
      sum
    end
    
    def has_unset_path_to_ancestor?(node, evidence)
      returnval = false
      if self == node
        returnval = true
      else
        @parents.each do |p|
          next if evidence[p.name]
          returnval = true if p.has_ancestor?(node)
        end
      end
      returnval        
    end
    
    # Returns true if the passed-in node is
    # a direct ancestor of this node and all
    # paths to it are blocked by nodes with
    # set evidence
    def is_explained_away?(node, evidence)
      returnval = true
      if self == node
        returnval = false
      else
        @parents.each do |p|
          next if evidence[p.name]
          returnval = false unless p.is_explained_away?(node, evidence)
        end
      end
      returnval
    end

  private
    def seek_state
      sum = 0.0
      num = rand
      returnval = nil
      @states.each do |s|
        returnval = s
        sum += yield(s)
        break if num < sum
      end
      returnval      
    end
  
    def state_combinations
      all_states = []
      @parents.each {|p| all_states << p.states }
      all_states << @states
      Combination.new(all_states).to_a
    end
  
    def remove_irrelevant_states(probabilities, state, evidence)
      # remove the states for this node
      probabilities.reject! {|e| e.first.last != state }
      index = 0
      @parents.each do |parent|
        raise "Marginal cannot be evaluated because not all parent nodes are set" unless evidence.has_key?(parent.name)
        probabilities.reject! {|e| e.first[index] != evidence[parent.name] }
        index += 1
      end
      probabilities
    end
    
    def evaluate_markov_blanket(state, event)
      returnval = 1.0
      temp_probs = @probability_table.dup
      remove_irrelevant_states(temp_probs, state, event)
      temp = event[@name]
      event[@name] = state
      returnval *= evaluate_marginal(state, event)
      @children.each {|child| returnval *= child.evaluate_marginal(event[child.name], event) }
      event[@name] = temp
      returnval
    end
  end
end