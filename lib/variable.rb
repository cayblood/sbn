class Sbn
  class Variable
    attr_reader :name, :states, :parents, :children, :probability_table
    
    def initialize(net, name = '', probabilities = [0.5, 0.5], states = [:true, :false])
      @net = net
      @@variable_count ||= 0
      @@variable_count += 1
      name = "variable_#{@@variable_count}" if name.is_a? String and name.empty?
      @name = name.to_underscore_sym
      @children = []
      @parents = []
      @states = []
      @state_frequencies = {} # used for storing training data
      set_states(states)
      set_probabilities(probabilities)
      net.add_variable(self)
    end
    
    def ==(obj); test_equal(obj); end
    def eql?(obj); test_equal(obj); end
    def ===(obj); test_equal(obj); end

    def to_s
      @name.to_s
    end
    
    def to_xmlbif_variable(xml)
      xml.variable(:type => "nature") do
        xml.name(@name.to_s)
        @states.each {|s| xml.outcome(s.to_s) }
        xml.property("SbnVariableType = #{self.class.to_s}")
        yield(xml) if block_given?
      end
    end
    
    def to_xmlbif_definition(xml)
      xml.definition do
        xml.for(@name.to_s)
        @parents.each {|p| xml.given(p.name.to_s) }
        xml.table(@probability_table.transpose.last.join(' '))
        yield(xml) if block_given?
      end
    end
    
    def evidence_name
      @name
    end
    
    def add_child(variable)
      return if variable == self or @children.include?(variable)
      variable.add_parent_no_recurse(self)
      unless variable.is_a?(StringVariable)
        @children << variable
        variable.generate_probability_table
      end
    end
    
    def add_child_no_recurse(variable)
      return if variable == self or @children.include?(variable)
      @children << variable unless variable.is_a?(StringVariable)
    end
    
    def add_parent(variable)
      return if variable == self or @parents.include?(variable)
      variable.add_child_no_recurse(self)
      unless variable.is_a?(StringVariable)
        @parents << variable
        generate_probability_table
      end
    end
    
    def add_parent_no_recurse(variable)
      return if variable == self or @parents.include?(variable)
      @parents << variable unless variable.is_a?(StringVariable)
    end
    
    def set_states(states)
      states.symbolize_values!
      @states = states
      generate_probability_table
    end
    
    def set_probability(probability, event)
      event = @net.symbolize_evidence(event)
      c = [event[@name]]
      index = state_combinations.index(c)
      @probabilities[index] = probability
      generate_probability_table
    end
    
    def set_probabilities(probs)
      @probabilities = probs
      generate_probability_table
    end
    
    def set_in_evidence?(evidence)
      evidence.has_key?(evidence_name)
    end
    
    def get_observed_state(evidence)
      evidence[@name]
    end

  	# A variable can't be evaluated unless its parents have
  	# been observed    
    def can_be_evaluated?(evidence)
      returnval = true
      parents.each {|p| returnval = false unless p.set_in_evidence?(evidence) }
      returnval
    end
    
  	# In order to draw uniformly from the probabilty space, we can't
  	# just pick a random state.  Instead we generate a random number
  	# between zero and one and iterate through the states until the 
  	# cumulative sum of their probabilities exceeds our random number.    
    def get_random_state(event = {})
#      event = @net.symbolize_evidence(event)
      seek_state {|s| evaluate_marginal(s, event) }
    end
    
  	# similar to get_random_state() except it evaluates a variable's markov
  	# blanket in addition to the variable itself.
    def get_random_state_with_markov_blanket(event)
#      event = @net.symbolize_evidence(event)
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
    
    def transform_evidence_value(val)
      val.to_underscore_sym
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
      # remove the states for this variable
      probabilities.reject! {|e| e.first.last != state }
      index = 0
      @parents.each do |parent|
        unless parent.set_in_evidence?(evidence)
          raise "Marginal cannot be evaluated because there are unset parent variables"
        end
        probabilities.reject! {|e| e.first[index] != parent.get_observed_state(evidence) }
        index += 1
      end
      probabilities
    end
    
    def evaluate_markov_blanket(state, event)
      returnval = 1.0
      temp_probs = @probability_table.dup
      remove_irrelevant_states(temp_probs, state, event)
      temp = get_observed_state(event)
      event[@name] = state
      returnval *= evaluate_marginal(state, event)
      @children.each {|child| returnval *= child.evaluate_marginal(child.get_observed_state(event), event) }
      event[@name] = temp
      returnval
    end

    def test_equal(variable)
      returnval = true
      returnval = false unless variable.class == self.class and self.is_a? Variable
      returnval = false unless returnval and @name == variable.name
      if returnval
        parent_names = []
        variable.parents.each {|p| parent_names << p.name.to_s }
        my_parent_names = []
        @parents.each {|p| my_parent_names << p.name.to_s }
        returnval = false unless parent_names.sort == my_parent_names.sort
        returnval = false unless @states == variable.states
        table = variable.probability_table.transpose.last
        my_table = @probability_table.transpose.last
        returnval = false unless table == my_table
      end
      returnval
    end
  end
end