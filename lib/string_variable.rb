require File.dirname(__FILE__) + '/variable'

class Sbn
  class StringCovariable < Variable
    def initialize(net, manager_name, text_to_match, probabilities)
      @manager_name = manager_name
      @text_to_match = text_to_match.downcase
      super(net, "#{@manager_name}_covar_#{@text_to_match}", probabilities)
    end
    
    def evidence_name
      @manager_name
    end
    
    def get_observed_state(evidence)
      evidence[@manager_name].include?(@text_to_match) ? :true : :false
    end
  end
  
  class StringVariable < Variable
    attr_reader :covariables
    
    def initialize(net, name = '')
      @net = net
      @covariables = {}
      @covariable_children = []
      @covariable_parents = []
      super(net, name)
    end
    
    # This node never influences the probabilities.  Its sole
    # responsibility is to manage the co-variables, so it should
    # always appear to be set in the evidence so that it won't
    # waste time in the inference process.
    def set_in_evidence?(evidence)
      true
    end
    
    # This node never has any parents or children.  It just
    # sets the parents or children of its covariables.
    def add_child(variable)
      return if variable == self
      @covariable_children << variable
      @covariables.each do |ng, covar|
        covar.add_child(variable)
        variable.add_parent_no_recurse(covar)
      end
    end
    
    def add_child_no_recurse(variable)
      @covariable_children << variable
      @covariables.each {|ng, covar| covar.add_child_no_recurse(variable) }
    end
    
    def add_parent(variable)
      return if variable == self
      @covariable_parents << variable
      @covariables.each do |ng, covar|
        covar.add_parent(variable)
        variable.add_child_no_recurse(covar)
      end
    end
    
    def add_parent_no_recurse(variable)
      @covariable_parents << variable
      @covariables.each {|ng, covar| covar.add_parent_no_recurse(variable) }
    end
    
    def generate_probability_table
      @covariables.each {|ng, covar| covar.generate_probability_table }
    end
    
    # create co-variables when new n-grams are encountered
    def add_training_set(evidence)
      val = evidence[@name].downcase.strip
      len = val.length
      ngrams = []
      
      # Make ngrams as small as 3 characters in length up to
      # the length of the string.  We may need to whittle this
      # down significantly to avoid severe computational burdens.
      (3..len).each {|n| ngrams.concat val.ngrams(n) }
      ngrams.uniq!
      ngrams.each do |ng|
        unless @covariables.has_key?(ng)
          # these probabilities are temporary and will get erased after training
          newcovar = StringCovariable.new(@net, @name, ng, [0.5, 0.5])
          count = 0
          @covariable_parents.each {|p| newcovar.add_parent(p) }
          @covariable_children.each {|p| newcovar.add_child(p) }
          @covariables[ng] = newcovar
          @net.add_variable(newcovar)
        end
        @covariables[ng].add_training_set(evidence)
      end
    end
  end
end