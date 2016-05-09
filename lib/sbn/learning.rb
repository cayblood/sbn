module Sbn
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

    def add_sample_point(evidence)
      # reject incomplete evidence sets
      raise "Incomplete sample points" unless is_complete_evidence?(evidence)
      
      # Because string variables add new variables to the net during learning,
      # the process of determining state frequencies has to be deferred until
      # the end.  For now, we'll just store the evidence and use it later.
      @sample_points ||= []
      @sample_points << evidence
    end

    def set_probabilities_from_sample_points!
      return unless @sample_points
      accumulate_state_frequencies
      
      # find the sums for each parent combination so we
      # know how to normalize their associated states
      sums = {}
      state_combinations.each do |comb|
        parent_comb = comb.dup

        # remove state for this node so that all
        # that is left is the parent combination
        parent_comb.pop
        @state_frequencies[comb] ||= 0
        sums[parent_comb] ||= 0

        sums[parent_comb] += @state_frequencies[comb]
      end

      probabilities = []
      count_of_zero_prob_states = count_of_nonzero_prob_states = {}
      state_combinations.each do |comb|
        parent_comb = comb.dup
        parent_comb.pop
        prob = @state_frequencies[comb] / sums[parent_comb].to_f
        probabilities << (prob == 0.0 ? NEGLIGIBLE_PROBABILITY : prob)
        
        # Keep track of how many of this node's states were
        # empty for this particular parent combination, so that
        # we can pad them with tiny numbers later.  Otherwise,
        # some exact inference algorithms will fail.
        if prob == 0.0
          count_of_zero_prob_states[parent_comb] ||= 0
          count_of_zero_prob_states[parent_comb] += 1
        else
          count_of_nonzero_prob_states[parent_comb] ||= 0
          count_of_nonzero_prob_states[parent_comb] += 1
        end
      end
      
      # pad the zero probabilities
      count = 0
      state_combinations.each do |comb|
        parent_comb = comb.dup
        parent_comb.pop
        amount_to_subtract = count_of_zero_prob_states[parent_comb] *
                             NEGLIGIBLE_PROBABILITY /
                             count_of_nonzero_prob_states[parent_comb].to_f
        p = probabilities[count]
        p = (p > NEGLIGIBLE_PROBABILITY ? p - amount_to_subtract : p)
        probabilities[count] = p
        count += 1
      end
      
      # assign new probabilities
      set_probabilities(probabilities)
    end

  private
    def accumulate_state_frequencies
      @sample_points.each do |evidence|
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
    def learn(data)
      data.each {|evidence| add_sample_point(evidence) }
      set_probabilities_from_sample_points!
    end
    
    def add_sample_point(evidence)
      evidence = symbolize_evidence(evidence)
      @variables.keys.each {|key| @variables[key].add_sample_point(evidence) }
    end
    
    def set_probabilities_from_sample_points!
      # we must first conduct learning on parents then their children
      unlearned_variables = @variables.keys
      
      count = 0
      until unlearned_variables.empty?
        learnable_variables = @variables.reject do |name, var|
          reject = false
          var.parents.each {|p| reject = true if unlearned_variables.include?(p.name) }
          reject
        end
        learnable_variables.keys.each do |key|
          @variables[key].set_probabilities_from_sample_points!
          count += 1
          unlearned_variables.delete(key)
        end
      end
    end
  end
end
