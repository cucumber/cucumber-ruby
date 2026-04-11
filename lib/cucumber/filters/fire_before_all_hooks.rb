# frozen_string_literal: true

module Cucumber
  module Filters
    # Executes all BeforeAll hooks and only if they were all
    # successful pass on the TestCases down the filter chain
    class FireBeforeAllHooks < Core::Filter.new(:config)
      def initialize(fire_before_all_hooks_method, receiver = nil)
        super
        @fire_before_all_hooks_method = fire_before_all_hooks_method
        @test_cases = []
      end

      def test_case(test_case)
        @test_cases << test_case
        self
      end

      def done
        all_succeded = @fire_before_all_hooks_method.call
        if all_succeded
          @test_cases.map do |test_case|
            test_case.describe_to(@receiver)
          end
        end
        super
        self
      end
    end
  end
end
