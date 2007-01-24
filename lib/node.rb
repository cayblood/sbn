class Sbn
  class Node
    attr_accessor :name
    
    def initialize(name = '', states = [])
      @name = name
      @children = []
      @states = []
      @probabilities = {}
      set_states(states)
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
      @states = states
    end
    
    def set_probability(probability, event)
      
    end
    
  private
    def can_be_evaluated?(event)
      
    end
    
    def get_random_state(event)
      
    end
    
    def get_random_state_with_markov_blanket(event)
      
    end
    
    def remove_irrelevant_states(probabilities, state, evidence)
      
    end
    
    def evaluate_marginal(state, event)
      
    end
    
    def evaluate_markov_blanket(state, event)
      
    end    
  end
end