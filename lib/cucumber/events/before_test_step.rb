module Cucumber
  module Events
    class BeforeTestStep
      attr_reader :test_case, :test_step

      def initialize(test_case, test_step)
        @test_case, @test_step = test_case, test_step
      end
    end
  end
end
