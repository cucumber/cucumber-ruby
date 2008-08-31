module Cucumber
  module Tree
    class GivenScenario
      def initialize(scenario, name, line)
        @scenario, @name, @line = scenario, name, line
      end
      
      def steps
        @scenario.given_scenario_steps(@name)
      end
    end
  end
end
