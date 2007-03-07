# = SBN: Simple Bayesian Networks
# Copyright (C) 2005-2007  Carl Youngblood mailto:carl@youngbloods.org
# 
# SBN makes it easy to use Bayesian Networks in your ruby application. Why
# would you want to do this?  Bayesian networks are excellent tools for
# making intelligent decisions based on collected data.  They are used to
# measure and predict the probabilities of various outcomes in a problem
# space.
#
# A Bayesian Network is a directed acyclic graph representing the variables
# in a problem space, the causal relationships between these variables, and
# the probabilities of these variables' possible states.  It is also the
# algorithms used to calculate the most likely state of unobserved
# variables in the problem space. 
# 
# == Example
# Our sample network has four variables:
# * Cloudy: :true if sky is cloudy, :false if sky is sunny.
# * Sprinkler: :true if sprinklers were turned on, :false if not
# * Rain: :true if it rained, :false if not
# * GrassWet: :true if the grass is wet, :false if not
#
#  net       = Sbn::Net.new("Grass Wetness Belief Net")
#  cloudy    = Sbn::Variable.new(net, :cloudy, [0.5, 0.5])
#  sprinkler = Sbn::Variable.new(net, :sprinkler, [0.1, 0.9, 0.5, 0.5])
#  rain      = Sbn::Variable.new(net, :rain, [0.8, 0.2, 0.2, 0.8])
#  grass_wet = Sbn::Variable.new(net, :grass_wet, [0.99, 0.01, 0.9, 0.1, 0.9, 0.1, 0.0, 1.0])
#  cloudy.add_child(sprinkler)
#  cloudy.add_child(rain)
#  sprinkler.add_child(grass_wet)
#  rain.add_child(grass_wet)
#  evidence = {:sprinkler => :false, :rain => :true}
#  net.query_variable(:grass_wet)

class Sbn
  class Net
    attr_reader :name, :variables
    
    def initialize(name = '')
      @@net_count ||= 0
      @@net_count += 1
      @name = (name.empty? ? "net_#{@@net_count}" : name.to_underscore_sym)
      @variables = {}
      @evidence = {}
    end

    def ==(obj); test_equal(obj); end
    def eql?(obj); test_equal(obj); end
    def ===(obj); test_equal(obj); end
  
    def add_variable(variable)
      name = variable.name
      if @variables.has_key? name
        raise "Variable of same name has already been added to this net"
      end
      @variables[name] = variable
    end
    
    def symbolize_evidence(evidence)
      newevidence = {}
      evidence.each do |key, val|
        key = key.to_underscore_sym
        newevidence[key] = @variables[key].transform_evidence_value(val)
      end
      newevidence
    end
    
    def set_evidence(event)
      @evidence = symbolize_evidence(event)
    end

  private
    def test_equal(net)
      returnval = true
      returnval = false unless net.class == self.class and self.class == Net
      returnval = false unless net.name == @name
      returnval = false unless @variables.keys.map {|k| k.to_s}.sort == net.variables.keys.map {|k| k.to_s}.sort
      net.variables.each {|name, variable| returnval = false unless variable == @variables[name] }
      returnval
    end
  end
end
