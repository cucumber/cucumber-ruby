# frozen_string_literal: true

require 'cucumber/formatter/io'
require 'cucumber/formatter/message_builder'

module Cucumber
  module Formatter
    class Rerun < MessageBuilder
      include Formatter::Io

      def initialize(config)
        @io = ensure_io(config.out_stream, config.error_stream)
        @repository = Cucumber::Repository.new
        @query = Cucumber::Query.new(@repository)

        config.on_event :envelope, &method(:on_envelope)
        super(config)
      end

      def output_envelope(envelope)
        @repository.update(envelope)
        finish_report if envelope.test_run_finished
      end

      private

      def finish_report
        @query.find_all_test_case_started.each do |test_case|
          # Don't consider test cases without a pickle (Unsure what these could be?)
          pickle = @query.find_pickle_by(test_case)
          next if pickle.nil?

          # Sanitization: Skipped test cases are not considered failures (on their own)
          next if skipped?(test_case)

          # Sanitization: Passing test cases are not considered failures
          if passing?(test_case)
            # If a test case is passing on a retry - it must alleviate prior failures of the same case
            uri_and_location_hash[pickle.uri] - [pickle.location.line]
            next
          end

          # Sanitization: Finally before logging a failure, ensure we are not on a retried test case
          #   - i.e. if a test fails once, we don't log that it needs retrying multiple times
          next if test_case.attempt > 1

          # Store each failure in a Hash to be condensed into rerun text format
          uri_and_location_hash[pickle.uri] << pickle.location.line
        end

        # This outputs the desired failures in to the file
        @io.print(failure_array.join("\n"))
      end

      def failure_array
        uri_and_location_hash.map do |uri, lines|
          "#{uri}:#{lines.join(':')}"
        end
      end

      def uri_and_location_hash
        @uri_and_location_hash ||= Hash.new { |hash, key| hash[key] = [] }
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
