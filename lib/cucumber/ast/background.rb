require 'cucumber/ast/feature_element'

module Cucumber
  module Ast
    class Background
      include FeatureElement

      def initialize(comment, line, keyword, steps)
        @comment, @line, @keyword = comment, line, keyword
        attach_steps(steps)
        @steps = StepCollection.new(steps.map{|step| step.step_invocation})
      end

      def accept(visitor)
        visitor.visit_steps(@steps)
      end
    end
  end
end