# frozen_string_literal: true

require 'cucumber/formatter/io'
require 'cucumber/formatter/message_builder'

module Cucumber
  module Formatter
    class Rerun < MessageBuilder
      def initialize(config)
        @io = ensure_io(config.out_stream, config.error_stream)
        super(config)
      end

      def output_envelope(envelope)
        @repository.update(envelope)
        finish_report if envelope.test_run_finished
      end

      private

      def finish_report
        @query.find_all_test_case_started.each do |test_case|
          status = @query.find_most_severe_test_step_result_by(test_case).status

          # RULE: Don't log test cases without a pickle (We cannot query their location data to log them)
          pickle = @query.find_pickle_by(test_case)
          next if pickle.nil?

          # RULE: Test cases with the worst result as Passing is not considered a failure (Don't log these)
          if status == Cucumber::Messages::TestStepResultStatus::PASSED
            # If the test case in question had already been logged as a failure (And we're retrying), remove the prior reference of failure
            uri_and_location_hash[pickle.uri].delete(pickle.location.line)
            next
          end

          # RULE: Test cases with the worst result as Skipped/Pending/Undefined are not considered failures (don't log these)
          next if non_rerunnable_status?(status)

          # RULE: Before logging a failure, ensure we are not on a retried test case (Don't log a retry multiple times)
          next if test_case.attempt > 1

          # Log the failure if every other skip rule has not been met, and the failure has not already been logged
          uri_and_location_hash[pickle.uri] << pickle.location.line
        end

        # Generate the final output from the logged failures to be formatted in the io output
        @io.print(failure_array.join("\n"))
      end

      def failure_array
        uri_and_location_hash.filter_map do |uri, lines|
          "#{uri}:#{lines.join(':')}" if lines.any?
        end
      end

      def uri_and_location_hash
        @uri_and_location_hash ||= Hash.new { |hash, key| hash[key] = Set.new }
      end

      def non_rerunnable_status?(status)
        [
          Cucumber::Messages::TestStepResultStatus::SKIPPED,
          Cucumber::Messages::TestStepResultStatus::PENDING,
          Cucumber::Messages::TestStepResultStatus::UNDEFINED
        ].include?(status)
      end
    end
  end
end
