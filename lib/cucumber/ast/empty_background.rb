require 'cucumber/ast/step_collection'

module Cucumber
  module Ast
    class EmptyBackground
      attr_writer :file
      attr_accessor :feature

      def failed?
        false
      end

      def feature_elements
        []
      end

      def step_collection(step_invocations)
        StepCollection.new(step_invocations)
      end

      def step_invocations
        []
      end

      def init
      end

      def accept(visitor)
      end
    end
  end
end

