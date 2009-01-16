module Cucumber
  module Ast
    class Features
      attr_reader :step_count, :scenarios

      def initialize
        @features = []

        @step_count = Hash.new{|counts, status| counts[status] = 0}
        @scenarios = []
      end

      def add_feature(feature)
        feature.features = self
        @features << feature
      end
      
      def step_executed(scenario, step_status)
        @scenarios << scenario unless @scenarios.index(scenario)
        @step_count[step_status] += 1
      end

      def accept(visitor)
        @features.each do |feature|
          visitor.visit_feature(feature)
        end
      end
    end
  end
end