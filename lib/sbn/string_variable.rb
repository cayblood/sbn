module Sbn
  class StringCovariable < Variable # :nodoc:
    attr_reader :text_to_match

    def self.from_json(net, json)
      json = JSON.load(json) unless json.is_a?(Hash)

      new(net, json[:manager_name], json[:text_to_match], json[:probabilities]).tap do |var|
        var.set_probability_table json[:probability_table]
      end
    end
    
    def initialize(net, manager_name, text_to_match)
      @@covar_count ||= 0
      @@covar_count += 1
      @manager_name = manager_name
      @text_to_match = text_to_match.downcase
      super(net, "#{@manager_name}_covar_#{@@covar_count}")
    end
    
    def to_xmlbif_variable(xml)
      super(xml) do |x|
        x.property("ManagerVariableName = #{@manager_name.to_s}")
        x.property("TextToMatch = #{@text_to_match.inspect}")
      end
    end

    def to_json_variable
      super.merge text_to_match: @text_to_match, manager_name: @manager_name
    end
    
    def evidence_name # :nodoc:
      @manager_name
    end
    
    def get_observed_state(evidence) # :nodoc:
      evidence[@manager_name].include?(@text_to_match) ? :true : :false
    end
    
    def transform_evidence_value(val) # :nodoc:
      raise "Evidence should not be provided for string covariables"
    end
    
    def set_in_evidence?(evidence) # :nodoc:
      evidence.has_key?(@manager_name)
    end

  private
    def test_equal(covariable)
      returnval = true
      returnval = false unless self.class == covariable.class and self.is_a? StringCovariable
      returnval = false unless returnval and @manager_name == covariable.instance_eval('@manager_name')
      returnval = false unless returnval and @text_to_match == covariable.instance_eval('@text_to_match')
      returnval = false unless returnval and super(covariable)
      returnval
    end
  end
  
  class StringVariable < Variable
    DEFAULT_NGRAM_SIZES = [3, 5, 10]
    attr_reader :ngram_sizes
    
    def initialize(net, name = '', options = {})
      @net = net
      @covariables = {}
      @covariable_children = []
      @covariable_parents = []
      @ngram_sizes = options.fetch(:ngram_sizes, DEFAULT_NGRAM_SIZES)
      super(net, name, [], [])
    end

    # create co-variables when new n-grams are encountered
    def add_sample_point(evidence) # :nodoc:
      val = evidence[@name].downcase.strip
      ngrams = []
      
      # Make ngrams as small as 3 characters in length up to
      # the length of the string.  We may need to whittle this
      # down significantly to avoid severe computational burdens.
      @ngram_sizes.each {|n| ngrams.concat val.ngrams(n) }
      ngrams.uniq!
      ngrams.each do |ng|
        unless @covariables.has_key?(ng)
          newcovar = StringCovariable.new(@net, @name, ng)
          @covariable_parents.each {|p| newcovar.add_parent(p) }
          @covariable_children.each {|p| newcovar.add_child(p) }
          @covariables[ng] = newcovar
        end
        @covariables[ng].add_sample_point(evidence)
      end
    end
    
    # returns an array of the variable's string covariables in alphabetical order
    def covariables # :nodoc:
      @covariables.keys.sort.map {|key| @covariables[key] }
    end
    
    def to_xmlbif_variable(xml) # :nodoc:
      super(xml) do |x|
        covars = @covariables.keys.sort
        parents = @covariable_parents.map {|p| p.name }
        x.property("Covariables = #{covars.join(',')}") unless covars.empty?

        # A string variable's parents cannot be specified in the "given"
        # section below, because only its covariables actually have them.
        x.property("Parents = #{parents.join(',')}") unless parents.empty?
      end
    end
    
    def to_xmlbif_definition(xml) # :nodoc:
      # string variables do not have any direct probabilities--only their covariables
    end
    
    # This node never influences the probabilities.  Its sole
    # responsibility is to manage the co-variables, so it should
    # always appear to be set in the evidence so that it won't
    # waste time in the inference process.
    def set_in_evidence?(evidence) # :nodoc:
      true
      # raise "String variables should never be used in inference--only their covariables"
    end
    
    # This method is used when reconstituting saved networks
    def add_covariable(covariable) # :nodoc:
      @covariable_children.each {|child| covariable.add_child(child) }
      @covariable_parents.each {|parent| covariable.add_parent(parent) }
      @covariables[covariable.text_to_match] = covariable
    end
    
    # This node never has any parents or children.  It just
    # sets the parents or children of its covariables.
    def add_child_no_recurse(variable) # :nodoc:
      return if variable == self or @covariable_children.include?(variable)
      if variable.is_a?(StringVariable)
        @covariable_children.concat variable.covariables
        @covariables.each {|ng, covar| variable.covariables.each {|varcovar| covar.add_child(varcovar) } }
      else
        @covariable_children << variable
        @covariables.each {|ng, covar| covar.add_child(variable) }
      end
      variable.generate_probability_table
    end
    
    def add_parent_no_recurse(variable) # :nodoc:
      return if variable == self or @covariable_parents.include?(variable)
      if variable.is_a?(StringVariable)
        @covariable_parents.concat variable.covariables
        @covariables.each {|ng, covar| variable.covariables.each {|varcovar| covar.add_parent(varcovar) } }
      else
        @covariable_parents << variable
        @covariables.each {|ng, covar| covar.add_parent(variable) }
      end
      generate_probability_table
    end
    
    def generate_probability_table # :nodoc:
      @covariables.each {|ng, covar| covar.generate_probability_table }
    end
    
    def is_complete_evidence?(evidence) # :nodoc:
      parent_names = @covariable_parents.map {|p| p.name.to_s }
      super(evidence) {|varnames| varnames.concat(parent_names) }
    end
    
    def transform_evidence_value(val) # :nodoc:
      val.to_s.downcase
    end
    
  private
    def test_equal(variable)
      returnval = true
      returnval = false unless self.class == variable.class and self.is_a? StringVariable
      returnval = false unless returnval and @name == variable.name
      returnval = false unless returnval and @covariable_children == variable.instance_eval('@covariable_children')
      returnval = false unless returnval and @covariable_parents == variable.instance_eval('@covariable_parents')
      @covariables.each do |key, val|
        break unless returnval
        returnval = false unless val == variable.instance_eval("@covariables[:#{key.to_s}]")
      end
      returnval
    end
  end
end
