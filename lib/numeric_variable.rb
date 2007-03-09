require File.dirname(__FILE__) + '/variable'

class Sbn
  class NumericVariable < Variable
    DEFAULT_FIRST_STDEV_STATE_COUNT = 14
    DEFAULT_SECOND_STDEV_STATE_COUNT = 6
    
    attr_reader :state_thresholds
    
    def initialize(net, name, probabilities = [], state_thresholds = [], options = {})
      @state_count_one = options.fetch(:first_stdev_state_count, DEFAULT_FIRST_STDEV_STATE_COUNT).to_f.round
      @state_count_two = options.fetch(:second_stdev_state_count, DEFAULT_SECOND_STDEV_STATE_COUNT).to_f.round
      @state_count_one += 1 if @state_count_one.odd?
      @state_count_two += 1 if @state_count_two.odd?
      @state_thresholds = state_thresholds
      states = generate_states_from_thresholds
      super(net, name, probabilities, states)
    end

    # alter the state table based on the variance of the training data
    def set_probabilities_from_training_data! # :nodoc:
      values = []
      @training_data.each {|evidence| values << evidence[@name] }
      stdev = values.standard_deviation
      average = values.average
      increment_amount_for_first_stdev = stdev * 2.0 / @state_count_one.to_f
      increment_amount_for_second_stdev = stdev * 2.0 / @state_count_two.to_f
      current_position = average - (stdev * 2.0)
      @state_thresholds = []
      
      # start on the left, two standard deviations away from the average
      (@state_count_two / 2).times do
        @state_thresholds << current_position
        current_position += increment_amount_for_second_stdev
      end

      # continue to add thresholds within the first standard deviation
      @state_count_one.times do
        @state_thresholds << current_position
        current_position += increment_amount_for_first_stdev
      end

      # add thresholds to the second standard deviation on the right
      (@state_count_two / 2).times do
        @state_thresholds << current_position
        current_position += increment_amount_for_second_stdev
      end
      @states = generate_states_from_thresholds
      
      # Now that states have been determined, call parent
      # class to finish processing training data.
      super
    end
    
    def to_xmlbif_variable(xml) # :nodoc:
      super(xml) {|x| x.property("StateThresholds = #{@state_thresholds.join(',')}") }
    end
    
    def get_observed_state(evidence) # :nodoc:
      num = evidence[@name]
      thresholds = @state_thresholds.dup
      index = 0
      t = thresholds.shift
      while num >= t and !thresholds.empty? do
        t = thresholds.shift
        index += 1
      end
      index += 1 if num >= t and thresholds.empty?
      @states[index]
    end

    def transform_evidence_value(val) # :nodoc:
      val.to_f
    end
    
  private
    def generate_states_from_thresholds
      returnval = []
      unless @state_thresholds.empty?
        th = @state_thresholds.map {|t| t.to_s.sub('\.', '_') }
        th.each_index do |i|
          if i == 0
            returnval << "lt#{th[0]}"
          else
            returnval << "gte#{th[i - 1]}lt#{th[i]}"
          end
        end
        returnval << "gte#{th[th.size - 1]}"
        returnval.map! {|state| state.to_sym }
      end
      returnval
    end
  end
end