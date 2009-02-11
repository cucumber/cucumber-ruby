module Cucumber
  module Ast
    # Holds an Array of Step or StepDefinition
    class StepCollection
      def initialize(steps)
        @steps = steps
        @steps.each{|step| step.step_collection = self}
      end

      def accept(visitor)
        @steps.each do |step|
          visitor.visit_step(step)
        end
      end

      def previous_step(step)
        i = @steps.index(step) || -1
        @steps[i-1]
      end
    end
  end
end