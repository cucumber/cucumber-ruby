module Cucumber
  module Events
    class AfterTestStep
      attr_reader :test_case, :test_step, :result

      def initialize(test_case, test_step, result)
        @test_case, @test_step, @result = test_case, test_step, result
      end
    end
  end
end
