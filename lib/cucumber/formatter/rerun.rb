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
          # RULE: Don't log test cases without a pickle (Unsure what these could be?)
          pickle = @query.find_pickle_by(test_case)
          next if pickle.nil?

          # RULE: (Configuration specific)
          #   -> If the test case has already been logged (And so we're retrying), we remove prior references of failures
          if passing?(test_case) && !rerun_flaky_tests?
            uri_and_location_hash[pickle.uri].delete(pickle.location.line)
            next
          end

          # RULE: (Configuration specific - to be amended once CCK conformance is finalised)
          #   -> If the strict configuration permits the result - handle it accordingly
          next if status == 'UNDEFINED' && !@config.strict.strict?(:undefined)
          next if status == 'PENDING' && !@config.strict.strict?(:pending)

          # RULE: Passing test cases are not considered failures (Don't log these)
          next if passing?(test_case)

          # RULE: Skipped test cases are not considered failures (on their own, don't log these)
          next if skipped?(test_case)

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

      def rerun_flaky_tests?
        @config.strict.strict?(:flaky)
      end

      def passing?(test_case_started)
        most_severe_test_step_result = @query.find_most_severe_test_step_result_by(test_case_started)
        most_severe_test_step_result.status == Cucumber::Messages::TestStepResultStatus::PASSED
      end

      def skipped?(test_case_started)
        most_severe_test_step_result = @query.find_most_severe_test_step_result_by(test_case_started)
        most_severe_test_step_result.status == Cucumber::Messages::TestStepResultStatus::SKIPPED
      end
    end
  end
end
