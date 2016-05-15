require 'cucumber/core/filter'
require 'cucumber/running_test_case'
require 'cucumber/events/bus'
require 'cucumber/events/after_test_case'

module Cucumber
  module Filters
    class Retry < Core::Filter.new(:configuration)

      def test_case(test_case)
        configuration.on_event(:after_test_case) do |event|
          next unless event.test_case == test_case
          next unless event.result.failed?
          next if test_case_counts[test_case] >= configuration.retry_attempts

          test_case_counts[test_case] += 1
          event.test_case.describe_to(receiver)
        end

        super
      end

      def test_case_counts
        @test_case_counts ||= Hash.new {|h,k| h[k] = 0 }
      end
    end
  end
end
