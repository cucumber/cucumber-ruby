require 'cucumber/ast/step_collection'

module Cucumber
  module Ast
    class EmptyBackground
      def failed?
        false
      end

      def feature_elements
        []
      end

      def step_collection(step_invocations)
        StepCollection.new(step_invocations)
      end

      def init
      end
    end
  end
end

