module Cucumber
  module Events
    class AfterTestCase
      attr_reader :test_case, :result

      def initialize(test_case, result)
        @test_case, @result = test_case, result
      end
    end
  end
end
