require File.dirname(__FILE__) + '/variable'

class Sbn
  class NumericVariable < Variable
    def initialize(net, probabilities = [], states = [])
    end
    
    def get_observed_state(evidence)      
    end
    
    def add_training_set(evidence)
    end
    
    # alter the state table based on the stdev of the training data
    def set_probabilities_from_training_data
    end
  end
end