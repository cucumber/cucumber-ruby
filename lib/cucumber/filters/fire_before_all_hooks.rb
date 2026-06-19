# frozen_string_literal: true

module Cucumber
  module Filters
    # Executes all BeforeAll hooks and ONLY if they were all
    # successful pass on all the `TestCase` objects down the filter chain
    class FireBeforeAllHooks < Core::Filter.new(:config)
      def initialize(support_code, receiver = nil)
        super
        @support_code = support_code
        @test_cases = []
      end

      def test_case(test_case)
        @test_cases << test_case
        self
      end

      def done
        if fire_before_all_hook
          @test_cases.map do |test_case|
            test_case.describe_to(@receiver)
          end
        end
        receiver.done
        self
      end

      private

      def fire_before_all_hook
        @support_code.fire_hook(:before_all)
      end
    end
  end
end
