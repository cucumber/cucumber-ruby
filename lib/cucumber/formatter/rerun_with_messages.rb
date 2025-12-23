# frozen_string_literal: true

require 'cucumber/formatter/io'

module Cucumber
  module Formatter
    class RerunWithMessages < MessageBuilder
      def initialize(config)
        @repository = Cucumber::Repository.new
        @query = Cucumber::Query.new(@repository)
        super(config)
      end

      def output_envelope(envelope)
        @repository.update(envelope)
        finish_report if envelope.test_run_finished
      end

      private

      # TODO: Fix this one method to make rerun formatter in new style
      def finish_report
        @query.find_all_test_case_started.each do |test_case|
          next if passing_or_skipped?(test_case)

          pickle = @query.find_pickle_by(test_case)
          next if pickle.nil?

          file = pickle.uri
          line = pickle.location
          uri_and_location_hash[file] << line

          # TODO: This outputs my desired failures in an array format. Now just to format to a file
          failure_array
        end
      end

      def failure_array
        uri_and_location_hash.map do |uri, lines|
          "#{uri}:#{lines.join(':')}"
        end
      end

      def uri_and_location_hash
        @uri_and_location_hash ||= Hash.new { |hash, key| hash[key] = [] }
      end

      def passing_or_skipped?(test_case_started)
        most_severe_test_step_result = @query.find_most_severe_test_step_result_by(test_case_started)
        [TestStepResultStatus::PASSED, TestStepResultStatus::SKIPPED].include?(most_severe_test_step_result.status)
      end
    end
  end
end
