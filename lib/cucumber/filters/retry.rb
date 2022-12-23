# frozen_string_literal: true

require 'cucumber/core/filter'
require 'cucumber/running_test_case'
require 'cucumber/events'

module Cucumber
  module Filters
    class Retry < Core::Filter.new(:configuration)
      def initialize(*_args)
        super
        @total_permanently_failed = 0
      end

      def test_case(test_case)
        configuration.on_event(:test_case_finished) do |event|
          next unless retry_required?(test_case, event)

          test_case_counts[test_case] += 1
          test_case.describe_to(receiver)
        end

        super
      end

      private

      def retry_required?(test_case, event)
        return false unless event.test_case == test_case

        return false unless event.result.failed?

        return false if @total_permanently_failed >= configuration.retry_total_tests

        retry_required = test_case_counts[test_case] < configuration.retry_attempts
        if retry_required
          # retry test
          true
        else
          # test failed after max. attempts
          @total_permanently_failed += 1
          false
        end
      end

      def test_case_counts
        @test_case_counts ||= Hash.new { |h, k| h[k] = 0 }
      end
    end
  end
end
