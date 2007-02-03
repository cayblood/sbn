class Sbn
  class Net
    # converts net to XMLBIF format
    # (http://www.cs.cmu.edu/afs/cs/user/fgcozman/www/Research/InterchangeFormat/)
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
          xml.name(@name.to_s.titleize)
          xml.text! "\n"
          xml.comment! "Variables"
          @nodes.each do |name, node|
            xml.variable(:type => "nature") do
              xml.name(name.to_s.titleize)
              node.states.each {|s| xml.outcome(s.to_s) }
            end
          end
          xml.text! "\n"
          xml.comment! "Probability distributions"
          @nodes.each do |name, node|
            xml.definition do
              xml.for(name.to_s.titleize)
              node.parents.each {|parent| xml.given(parent.name.to_s.titleize) }
              xml.table(node.probability_table.transpose.last.join(' '))
            end
          end
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
      
      # find nodes
      nodes = {}
      node_elements = doc['network'].first['variable'].each do |var|
        nodename = var['name'].first
        states = var['outcome']
        table = nil
        doc['network'].first['definition'].each do |defn|
          if defn['for'].first == nodename
            table = defn['table'].first.split.map {|prob| prob.to_f }
          end
        end
        nodes[nodename] = Node.new(nodename, states, table)
      end

      # find relationships between nodes
      doc['network'].first['definition'].each do |defn|
        nodename = defn['for'].first
        parents = defn['given']
        parents.each {|p| nodes[nodename].add_parent(nodes[p]) } if parents
      end
      returnval << nodes.values
      returnval
    end
  end
end