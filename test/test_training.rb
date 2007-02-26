require 'test/unit'
require File.dirname(__FILE__) + '/../lib/sbn4r'

class NetTest < Test::Unit::TestCase
  def setup
    @net = Sbn::Net.new("Categorization")
    @category = Sbn::Variable.new(@net, :category, [0.33, 0.33, 0.33], [:food, :groceries, :gas])
    @text = Sbn::StringVariable.new(@net, :text)
    @net << [@category, @text]
    @category.add_child(@text)
  end
  
  def teardown
  end

  def test_training
    @net.train([
      {:category => :food, :text => 'foo'},
      {:category => :food, :text => 'gro'},
      {:category => :food, :text => 'foo'},
      {:category => :food, :text => 'foo'},
      {:category => :groceries, :text => 'gro'},
      {:category => :groceries, :text => 'gro'},
      {:category => :groceries, :text => 'foo'},
      {:category => :groceries, :text => 'gro'},
      {:category => :gas, :text => 'gas'},
      {:category => :gas, :text => 'gas'},
      {:category => :gas, :text => 'gas'},
      {:category => :gas, :text => 'gas'}
    ])
    @net.variables.each do |k, v|
      p v.name
      p v.probability_table
      v.parents.each {|p| p p.name }
      puts
      puts
    end
    assert true
  end
end