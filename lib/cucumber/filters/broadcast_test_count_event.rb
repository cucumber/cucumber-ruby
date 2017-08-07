# frozen_string_literal: true
module Cucumber
  module Filters
    # Added at the end of the filter chain to broadcast a list of
    # all of the test cases that have made it through the filters.
    class BroadcastTestCountEvent < Core::Filter.new(:config)
      def initialize(config, receiver=nil)
        super
        @count_first = config.count_first?
        @test_cases = []
      end

      def test_case(test_case)
        @test_cases << test_case
        test_case.describe_to(@receiver) unless @count_first
        self
      end

      def done
        config.notify :test_count, @test_cases
        if @count_first
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
