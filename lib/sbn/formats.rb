require 'active_support/core_ext/hash'
require 'builder'
require 'xmlsimple'

module Sbn
  class Net

    # Load the Variables from the JSON and hook up the parents for nodes that have them.
    #
    # @param json a hash or a JSON string to be parsed to the bayes net.
    #
    def self.from_json(json)
      json = JSON.load(json) unless json.is_a?(Hash)
      json_net = json.with_indifferent_access[:network]

      new(json_net[:name]).tap do |net|

        connect_parents = []

        json_net[:variables].each_with_index do |node, index|
          variable =  case
                      when node.has_key?(:state_thresholds)
                        NumericVariable.from_json(net, node)
                      else
                        Variable.from_json(net, node)
                      end

          connect_parents << [variable, node[:parents]] unless node[:parents].empty?
        end

        connect_parents.each do |var, parent_names|
          parents = parent_names.map { |n| net.variables[n] }
          parents.map { |p| var.add_parent p }
        end

      end
    end

    # Returns a JSON Approximation of XMLBIF
    #
    def to_json_bayes_net
      {
        version: '0.3',
        network: {
          name: @name,
          variables: @variables.values.map { |v| v.to_json_variable },
        }
      }
    end

    # Returns a string containing a representation of the network in XMLBIF format.
    # http://www.cs.cmu.edu/afs/cs/user/fgcozman/www/Research/InterchangeFormat
    def to_xmlbif
      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct!
      xml.comment! <<-EOS
      
        Bayesian network in XMLBIF v0.3 (BayesNet Interchange Format)
        Produced by SBN (Simple Bayesian Network library)
        Output created #{Time.now}
      EOS
      xml.text! "\n"
      xml.comment! "DTD for the XMLBIF 0.3 format"
      xml.declare! :DOCTYPE, :bif do
        xml.declare! :ELEMENT, :bif, :"(network)*"
        xml.declare! :ATTLIST, :bif, :version, :CDATA, :"#REQUIRED"
        xml.declare! :ELEMENT, :"network (name, (property | variable | definition)*)"
        xml.declare! :ELEMENT, :name, :"(#PCDATA)"
        xml.declare! :ELEMENT, :"variable (name, (outcome | property)*)"
        xml.declare! :ATTLIST, :"variable type (nature | decision | utility) \"nature\""
        xml.declare! :ELEMENT, :outcome, :"(#PCDATA)"
        xml.declare! :ELEMENT, :definition, :"(for | given | table | property)*"
        xml.declare! :ELEMENT, :for, :"(#PCDATA)"
        xml.declare! :ELEMENT, :given, :"(#PCDATA)"
        xml.declare! :ELEMENT, :table, :"(#PCDATA)"
        xml.declare! :ELEMENT, :property, :"(#PCDATA)"
      end
      xml.bif :version => 0.3 do
        xml.network do
          xml.name(@name.to_s)
          xml.text! "\n"
          xml.comment! "Variables"
          @variables.each {|name, variable| variable.to_xmlbif_variable(xml) }
          xml.text! "\n"
          xml.comment! "Probability distributions"
          @variables.each {|name, variable| variable.to_xmlbif_definition(xml) }
        end
      end
    end
    
    # Reconstitute a saved network.
    def self.from_xmlbif(source)
      # convert tags to lower case
      source.gsub!(/(<.*?>)/, '\\1'.downcase)
      
      doc = XmlSimple.xml_in(source)
      netname = doc['network'].first['name'].first
            
      # find net name
      returnval = Net.new(netname)
      
      # find variables
      count = 0
      variables = {}
      variable_elements = doc['network'].first['variable'].each do |var|
        varname = var['name'].first.to_sym
        properties = var['property']
        vartype = nil
        manager_name = nil
        text_to_match = ""
        options = {}
        thresholds = []
        properties.each do |prop|
          key, val = prop.split('=').map {|e| e.strip }
          vartype = val if key == 'SbnVariableType'
          manager_name = val if key == 'ManagerVariableName'
          text_to_match = eval(val) if key == 'TextToMatch'
          options[key.to_sym] = val.to_i if key =~ /stdev_state_count/
          thresholds = val.split(',').map {|e| e.to_f } if key == 'StateThresholds'
        end
        states = var['outcome']
        table = []
        doc['network'].first['definition'].each do |defn|
          if defn['for'].first.to_sym == varname
            table = defn['table'].first.split.map {|prob| prob.to_f }
          end
        end
        count += 1
        variables[varname] = case vartype
          when "Sbn::StringVariable" then StringVariable.new(returnval, varname)
          when "Sbn::NumericVariable" then NumericVariable.new(returnval, varname, table, thresholds, options)
          when "Sbn::Variable" then Variable.new(returnval, varname, table, states)
          when "Sbn::StringCovariable" then StringCovariable.new(returnval, manager_name, text_to_match, table)
        end
      end

      # find relationships between variables

      # connect covariables to their managers
      variable_elements = doc['network'].first['variable'].each do |var|
        varname = var['name'].first.to_sym
        properties = var['property']
        vartype = nil
        covars = nil
        parents = nil
        properties.each do |prop|
          key, val = prop.split('=').map {|e| e.strip }
          covars = val.split(',').map {|e| e.strip.to_sym } if key == 'Covariables'
          parents = val.split(',').map {|e| e.strip.to_sym } if key == 'Parents'
          vartype = val if key == 'SbnVariableType'
        end
        if vartype == "Sbn::StringVariable"
          parents.each {|p| variables[varname].add_parent(variables[p]) } if parents
          covars.each {|covar| variables[varname].add_covariable(variables[covar]) } if covars
        end
      end

      # connect all other variables to their parents
      doc['network'].first['definition'].each do |defn|
        varname = defn['for'].first.to_sym
        parents = defn['given']
        parents.each {|p| variables[varname].add_parent(variables[p.to_sym]) } if parents
      end
      returnval
    end
  end
end
