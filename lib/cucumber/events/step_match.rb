module Cucumber
  module Events
    class StepMatch
      attr_reader :test_step, :step_match

      def initialize(test_step, step_match)
        @test_step, @step_match = test_step, step_match
      end
    end
  end
end
