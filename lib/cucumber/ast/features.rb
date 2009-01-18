module Cucumber
  module Ast
    class Features
      attr_reader :steps, :scenarios

      def initialize
        @features = []

        @steps = Hash.new{|steps, status| steps[status] = []}
        @scenarios = []
      end

      def add_feature(feature)
        feature.features = self
        @features << feature
      end
      
      def step_executed(step)
        @scenarios << step.scenario unless @scenarios.index(step.scenario)
        @steps[step.status] << step
      end

      def accept(visitor)
        @features.each do |feature|
          visitor.visit_feature(feature)
        end
      end
    end
  end
end