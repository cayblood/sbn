class Sbn
  class Node
    attr_accessor :name
    
    def initialize(name = '', states = [])
      @name = name
      set_states(states)
    end
    
    def add_child(node)
      return if child == 
    end
    
    def add_parent(node)
      
    end
    
    def set_states(states)
      
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