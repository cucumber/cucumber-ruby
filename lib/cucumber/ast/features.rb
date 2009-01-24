module Cucumber
  module Ast
    class Features
      attr_reader :steps, :scenarios

      def initialize(filter)
        @filter = filter

        @features = []
        @scenarios = []
        @steps = Hash.new{|steps, status| steps[status] = []}
      end

      def add_feature(feature)
        feature.features = self
        @features << feature
      end

      def visit?(node, lines)
        @filter.matched?(node) &&
        (lines.empty? ? true : node.at_lines?(lines))
      end

      def scenario_executed(scenario)
        @scenarios << scenario
      end
      
      def step_executed(step)
        @steps[step.status] << step
      end

      def accept(visitor)
        @features.each do |feature|
          visitor.visit_feature(feature) if visit?(feature, [])
        end
      end
    end
  end
end