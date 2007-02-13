class Sbn
  class Net
    # Expects data to be an array of hashes containing complete sets of evidence
    # for all nodes in the network.  Constructs probability tables for each node
    # based on the data.
    def train(data)
      # discard incomplete evidence sets
      nodenames = @nodes.keys.sort
      data.reject! {|evidence_set| evidence_set.keys.sort != nodenames }

      # create a hash that contains an empty probability table for each node
      node_state_frequencies = {}
      @nodes.each do |key, val|
        state_combinations = val.probability_table.transpose.first
        node_state_frequencies[key] = {}
        state_combinations.collect! {|comb| node_state_frequencies[comb] = 0 }
      end
      
      # iterate through each piece of evidence and keep track of the frequency
      # of each combination
      data.each do |evidence|
        @nodes.each do |key, val|
          combination_instance = []
          val.parents.each {|p| combination_instance << evidence[p.name]}
          combination_instance << evidence[key]
          node_state_frequencies[key][combination_instance] += 1
        end
      end
      
      # normalize probabilities for each node
      NEGLIGIBLE_PROBABILITY = 0.0001
      node_state_probabilities = {}
      @nodes.each do |key, val|
        sum = 0
        node_state_frequencies[key].values.each {|val| sum += val }
        probabilities = []
        state_combinations = val.probability_table.transpose.first
        count_of_zero_prob_states = 0
        state_combinations.each do |comb|
          prob = node_state_probabilities[key][comb] / sum
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
        val.set_probabilities(probabilities)
      end
    end
  end
end