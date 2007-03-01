require File.dirname(__FILE__) + '/variable'

class Sbn
  class NumericVariable < Variable
    DEFAULT_FIRST_STDEV_STATE_COUNT = 14
    DEFAULT_SECOND_STDEV_STATE_COUNT = 6    
    
    def initialize(net, probabilities = [], states = [], options = {})
      @state_count_one = options.fetch(:first_stdev_state_count, DEFAULT_FIRST_STDEV_STATE_COUNT).to_f.round
      @state_count_two = options.fetch(:second_stdev_state_count, DEFAULT_SECOND_STDEV_STATE_COUNT).to_f.round
      @state_count_one += 1 if @state_count_one.odd?
      @state_count_two += 1 if @state_count_two.odd?
    end
    
    def get_observed_state(evidence)
      num = evidence[@name]
      thresholds = @state_thresholds.dup
      index = 0
      begin
        t = thresholds.shift
        index += 1
      end until num > t
      returnval = nil
      if index == 0
        returnval = [nil, @state_thresholds[0]]
      elsif index < @state_thresholds.size
        returnval = [@state_thresholds[index - 1], @state_thresholds[index]]
      else
        returnval = [@state_thresholds[index - 1], nil]
      end
      returnval
    end
    
    # alter the state table based on the variance of the training data
    def set_probabilities_from_training_data
      values = []
      @training_data.each {|evidence| values << evidence[@name] }
      stdev = values.standard_deviation
      average = values.average
      increment_amount_for_first_stdev = stdev * 2.0 / @state_count_one.to_f
      increment_amount_for_second_stdev = stdev * 2.0 / @state_count_two.to_f
      current_position = average - (stdev * 2.0)
      
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

      # add thresholds to the last standard deviation
      (@state_count_two / 2).times do
        @state_thresholds << current_position
        current_position += increment_amount_for_second_stdev
      end
      
      @states = []
      @state_thresholds.each_index do |i|
        if i == 0
          @states << [nil, @state_thresholds[i]]
        else
          @states << [@state_thresholds[i - 1], @state_thresholds[i]]
        end
      end
      @states << [@state_thresholds[-1], nil]
      
      # Now that states have been determined, call parent
      # class to finish processing training data.
      super
    end
  end
end