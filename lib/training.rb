class Sbn
  class Variable
    NEGLIGIBLE_PROBABILITY = 0.0001

    def add_training_set(evidence)
      # reject incomplete evidence sets
      varnames = [@name]
      @parents.each {|p| varnames << p.name }
      varnames.sort!
      raise "Incomplete training data" unless varnames & evidence.keys.sort == varnames

      combination_instance = []
      @parents.each {|p| combination_instance << evidence[p.name]}
      combination_instance << evidence[@name]
      @state_frequencies[combination_instance] += 1
    end
    
    def set_probabilities_from_training_data
      sum = 0.0
      @state_frequencies.values.each {|val| sum += val.to_f }
      probabilities = []
      count_of_zero_prob_states = 0
      state_combinations.each do |comb|
        prob = @state_frequencies[comb] / sum.to_f
        probabilities << prob == 0 ? NEGLIGIBLE_PROBABILITY : prob / sum.to_f
        if prob == 0
          count_of_zero_prob_states += 1
        else
          count_of_nonzero_prob_states += 1
        end
      end
      
      # find states with no probability and give them a very small probabilty so
      # that inference won't fail
      amount_to_subtract = count_of_zero_prob_states * NEGLIGIBLE_PROBABILITY / count_of_nonzero_prob_states.to_f
      probabilities.collect! {|p| p > NEGLIGIBLE_PROBABILITY ? p - amount_to_subtract : p }
      
      # assign new probabilities
      set_probabilities(probabilities)
    end
  end
  
  class Net
    # Expects data to be an array of hashes containing complete sets of evidence
    # for all variables in the network.  Constructs probability tables for each variable
    # based on the data.
    def train(data)
      # discard incomplete evidence sets
      varnames = @variables.keys.sort
      data.reject! {|evidence_set| evidence_set.keys.sort != varnames }

      data.each {|evidence| @variables.each {|key, val| val.add_training_set(evidence) } }
      @variables.each {|key, val| val.set_probabilities_from_training_data }
    end
  end
end