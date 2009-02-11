module Cucumber
  module Ast
    class Steps
      def initialize(steps)
        @steps = steps
      end

      def accept(visitor)
        @steps.each do |step|
          visitor.visit_step(step)
        end
      end
    end
  end
end