class Sbn
  class Variable
    NEGLIGIBLE_PROBABILITY = 0.0001
    
    def is_complete_evidence?(evidence) # :nodoc:
      varnames = [evidence_name.to_s]
      @parents.each {|p| varnames << p.name.to_s }
      yield(varnames) if block_given?
      
      # ignore covariables when determining whether evidence is complete or not
      varnames.map! do |n|
        n = n.split('_').first if n =~ /covar/
        n
      end
      varnames.uniq!
      varnames.sort!
      
      keys = evidence.keys.map {|k| k.to_s }
      keys.sort!
      varnames & keys == varnames
    end

    def add_training_set(evidence)
      # reject incomplete evidence sets
      raise "Incomplete training data" unless is_complete_evidence?(evidence)
      
      # Because string variables add new variables to the net during training,
      # the process of determining state frequencies has to be deferred until
      # the end.  For now, we'll just store the evidence and use it later.
      # In the future, this code should be optimized to avoid unnecessary
      # duplication of training data.
      @training_data ||= []
      @training_data << evidence
    end

    def set_probabilities_from_training_data!
      return unless @training_data
      accumulate_state_frequencies
      sum = 0.0
      @state_frequencies.values.each {|val| sum += val.to_f }
      probabilities = []
      count_of_zero_prob_states = count_of_nonzero_prob_states = 0
      state_combinations.each do |comb|
        @state_frequencies[comb] ||= 0
        prob = @state_frequencies[comb] / sum.to_f
        probabilities << (prob == 0 ? NEGLIGIBLE_PROBABILITY : prob)
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

  private
    def accumulate_state_frequencies
      @training_data.each do |evidence|
        combination_instance = []
        @parents.each {|p| combination_instance << p.get_observed_state(evidence) }
        combination_instance << get_observed_state(evidence)
        @state_frequencies[combination_instance] ||= 0      
        @state_frequencies[combination_instance] += 1
      end
    end  
  end
  
  class Net
    # Expects data to be an array of hashes containing complete sets of evidence
    # for all variables in the network.  Constructs probability tables for each variable
    # based on the data.
    def train(data)
      data.each {|evidence| add_training_set(evidence) }
      set_probabilities_from_training_data!
    end
    
    def add_training_set(evidence)
      evidence = symbolize_evidence(evidence)
      @variables.each {|key, val| val.add_training_set(evidence) }
    end
    
    def set_probabilities_from_training_data!
      @variables.each {|key, val| val.set_probabilities_from_training_data! }
    end
  end
end