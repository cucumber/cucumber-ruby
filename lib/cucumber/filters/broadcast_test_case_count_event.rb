# frozen_string_literal: true
require 'cucumber/core/filter'

module Cucumber
  module Filters
    # Added at the end of the filter chain to broadcast a list of
    # all of the test cases that have made it through the filters.
    class BroadcastTestCaseCountEvent < Core::Filter.new(:config)
      def initialize(config, receiver=nil)
        super
      end

      def test_case(test_case)
        if handlers_exist?
          test_cases << test_case
        else
          test_case.describe_to(@receiver)
        end
        self
      end

      def done
        if handlers_exist?
          config.notify :test_case_count, test_cases
          test_cases.map do |test_case|
            test_case.describe_to(@receiver)
          end
        end
        super
        self
      end

      private

      def handlers_exist?
        @handlers_exist ||= config.event_bus.handlers_exist_for?(:test_case_count)
      end

      def test_cases
        @test_cases ||= []
      end
    end
  end
end
