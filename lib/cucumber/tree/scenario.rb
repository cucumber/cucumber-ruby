module Cucumber
  module Tree
    class BaseScenario
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
    end

    class Scenario < BaseScenario
      
      # If a table follows, the header will be stored here. Weird, but convenient.
      attr_accessor :table_header
      
      def initialize(feature, name, &proc)
        @feature, @name = feature, name
        @steps_and_given_scenarios = []
        instance_eval(&proc) if block_given?
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

      def row?
        false
      end
      
      def add_step(keyword, name, line)
        @steps_and_given_scenarios << Step.new(self, keyword, name, line)
      end
      
      def add_given_scenario(name, line)
        @steps_and_given_scenarios << GivenScenario.new(self, name, line)
      end

      def Given(name)
        add_step('Given', name, *caller[0].split(':')[1].to_i)
      end

      def When(name)
        add_step('When', name, *caller[0].split(':')[1].to_i)
      end

      def Then(name)
        add_step('Then', name, *caller[0].split(':')[1].to_i)
      end

      def And(name)
        add_step('And', name, *caller[0].split(':')[1].to_i)
      end

      attr_reader :name, :line

    end

    class RowScenario < BaseScenario
      attr_reader :line
      
      def initialize(feature, template_scenario, values, line)
        @feature, @template_scenario, @values, @line = feature, template_scenario, values, line
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