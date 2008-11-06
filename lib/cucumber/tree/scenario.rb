module Cucumber
  module Tree
    class BaseScenario
      attr_reader :feature

      def file
        @feature.file
      end

      def accept(visitor)
        steps.each do |step|
          if step.row?
            visitor.visit_row_step(step)
          else
            visitor.visit_regular_step(step)
          end
        end
      end

      def at_line?(l)
        line == l || steps.map{|s| s.line}.index(l)
      end

      def previous_step(step)
        i = steps.index(step)
        raise "Couldn't find #{step} among #{steps}" if i.nil?
        steps[i-1]
      end
      
      def pending?
        steps.empty?
      end
      
    end

    class Scenario < BaseScenario
      MIN_PADDING = 2
      INDENT = 2

      # If a table follows, the header will be stored here. Weird, but convenient.
      attr_reader :table_header
      attr_accessor :table_column_widths
      attr_reader :name, :line

      def initialize(feature, name, line, &proc)
        @feature, @name, @line = feature, name, line
        @steps_and_given_scenarios = []
        instance_eval(&proc) if block_given?
      end

      def table_header=  header
        @table_header = header
        update_table_column_widths header
      end

      def steps
        @steps ||= @steps_and_given_scenarios.map{|step| step.steps}.flatten
      end

      def given_scenario_steps(name)
        sibling_named(name).steps
      end

      def sibling_named(name)
        @feature.scenario_named(name)
      end

      def length
        @length ||= Cucumber.language['scenario'].jlength + 2 + (@name.nil? ? 0 : @name.jlength)
      end

      def max_line_length
        [length, max_step_length].max
      end

      def padding_length
        padding = (max_line_length - length) + MIN_PADDING
        padding += INDENT if length != max_line_length
        padding
      end

      def step_padding_length(step)
        padding = (max_line_length - step.length) + MIN_PADDING
        padding -= INDENT if length == max_line_length
        padding
      end

      def max_step_length
        @max_step_length ||= (steps.map{|step| step.length}.max || 0)
      end

      def update_table_column_widths values
        @table_column_widths ||= [0] * values.size
        @table_column_widths = @table_column_widths.zip(values).map {|max, value| [max, value.size].max}
      end

      def row?
        false
      end

      def create_step(keyword, name, line)
        step = Step.new(self, keyword, name, line)
        @steps_and_given_scenarios << step
        step
      end

      def create_given_scenario(name, line)
        given_scenario =  GivenScenario.new(self, name, line)
        @steps_and_given_scenarios << given_scenario
        given_scenario
      end

      def Given(name)
        create_step('Given', name, *caller[0].split(':')[1].to_i)
      end

      def When(name)
        create_step('When', name, *caller[0].split(':')[1].to_i)
      end

      def Then(name)
        create_step('Then', name, *caller[0].split(':')[1].to_i)
      end

      def And(name)
        create_step('And', name, *caller[0].split(':')[1].to_i)
      end

    end

    class RowScenario < BaseScenario
      attr_reader :line

      def initialize(feature, template_scenario, values, line)
        @feature, @template_scenario, @values, @line = feature, template_scenario, values, line
        template_scenario.update_table_column_widths values
      end

      def row?
        true
      end

      def name
        @template_scenario.name
      end

      def steps
        @steps ||= @template_scenario.steps.map do |template_step|
          args = []
          template_step.arity.times do
            args << @values.shift
          end
          RowStep.new(self, template_step, args)
        end
      end
    end
  end
end
