class Sbn
  class Net
    # Expects data to be an array of hashes containing complete sets of evidence
    # for all nodes in the network.  Constructs probability tables for each node
    # based on the data.
    def train(data)
      # discard incomplete evidence sets
      nodenames = @nodes.keys.sort
      data.reject! {|evidence_set| evidence_set.keys.sort != nodenames }

      @nodes.each {|n| n.set_probabilities(Array.new(n.probability_table.size, 0.0001)) }

    end
  end
end