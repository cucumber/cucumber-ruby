module Cucumber
  module Events
    class BeforeTestCase
      attr_reader :test_case

      def initialize(test_case)
        @test_case = test_case
      end
    end
  end
end
