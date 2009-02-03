module Cucumber
  module Ast
    class Steps
      def initialize(scenario)
        @scenario = scenario
      end

      def accept(visitor)
        @scenario.accept_steps(visitor)
      end
    end
  end
end