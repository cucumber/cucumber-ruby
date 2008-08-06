module Cucumber
  module Tree
    class BaseScenario
      def file
        @feature.file
      end

      def accept(visitor)
        steps.each do |step|
          visitor.visit_step(step)
        end
      end

      def at_line?(l)
        line == l || steps.map{|s| s.line}.index(l)
      end
    end

    class Scenario < BaseScenario
      
      # If a table follows, the header will be stored here. Weird, but convenient.
      attr_accessor :table_header
      
      def initialize(feature, name, &proc)
        @feature, @name = feature, name
        @steps = []
#        @line = *caller[2].split(':')[1].to_i
        instance_eval(&proc) if block_given?
      end

      def row?
        false
      end
      
      def add_step(keyword, name, line)
        @steps << Step.new(self, keyword, name, line)
      end

      def Given(name)
        add_step('Given', name, *caller[2].split(':')[1].to_i)
      end

      def When(name)
        add_step('When', name, *caller[2].split(':')[1].to_i)
      end

      def Then(name)
        add_step('Then', name, *caller[2].split(':')[1].to_i)
      end

      def And(name)
        add_step('And', name, *caller[2].split(':')[1].to_i)
      end

      attr_reader :name, :steps, :line

    end

    class RowScenario < BaseScenario
      attr_reader :line
      
      def initialize(feature, template_scenario, values, line)
        @feature, @template_scenario, @values, @line = feature, template_scenario, values, line
      end
      
      def row?
        true
      end

      def steps
        @steps ||= @template_scenario.steps.map do |template_step|
          args = template_step.args.map do
            @values.shift
          end
          RowStep.new(self, template_step.keyword, template_step.proc, args)
        end
      end
    end
  end
end