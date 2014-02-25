module Cucumber
  class Runtime
    class GatedReceiver
      def initialize(receiver)
        @receiver = receiver
        @test_cases = []
      end

      def test_case(test_case)
        @test_cases << test_case
      end

      def done
        @test_cases.map do |test_case|
          test_case.describe_to(@receiver)
        end
        @receiver.done
      end
    end
  end
end
