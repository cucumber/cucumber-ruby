# frozen_string_literal: true

require 'cucumber/core/filter'
require 'cucumber/running_test_case'
require 'cucumber/events'

module Cucumber
  module Filters
    class Retry < Core::Filter.new(:configuration)
      def test_case(test_case)
        configuration.on_event(:test_case_finished) do |event|
          next unless event.test_case == test_case
          next unless retry?(test_case, event.result)

          test_case.describe_to(receiver)
        end

        super
      end

      private

      def retry?(test_case, result)
        if retry_policy.will_be_retried?(test_case, result)
          retry_policy.record_retry(test_case)
          true
        else
          retry_policy.record_permanent_failure if result.failed?
          false
        end
      end

      def retry_policy = configuration.retry_policy
    end
  end
end
