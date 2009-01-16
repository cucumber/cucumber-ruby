module Cucumber
  module Ast
    class Features
      attr_reader :step_count

      def initialize
        @features = []

        @step_count = Hash.new{|counts, status| counts[status] = 0}
      end

      def add_feature(feature)
        feature.features = self
        @features << feature
      end
      
      def increment_step_count(step_status)
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