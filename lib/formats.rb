class Sbn
  class Net
    # converts net to XMLBIF format
    # http://www.cs.cmu.edu/afs/cs/user/fgcozman/www/Research/InterchangeFormat
    def to_xmlbif
      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct!
      xml.comment! <<-EOS
      
        Bayesian network in XMLBIF v0.3 (BayesNet Interchange Format)
        Produced by SBN4R (Simple Bayesian Network library for Ruby)
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
          text_to_match = val if key == 'TextToMatch'
          options[key.to_sym] = val.to_i if key =~ /stdev_state_count/
          thresholds = val.map {|e| e.to_f } if key == 'StateThresholds'
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