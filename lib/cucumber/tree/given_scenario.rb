module Cucumber
  module Tree
    class GivenScenario
      def initialize(scenario, name, line)
        @scenario, @name, @line = scenario, name, line
      end
    end
  end
end
