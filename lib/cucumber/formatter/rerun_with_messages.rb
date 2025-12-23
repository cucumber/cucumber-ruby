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
        # private void finishReport() {
        #         query.findAllTestCaseStarted().stream()
        #                 .filter(this::isNotPassingOrSkipped)
        #                 .map(query::findPickleBy)
        #                 .filter(Optional::isPresent) # get rid of nil values
        #                 .map(Optional::get)  # get rid of nil values
        #                 .map(this::createUriAndLine)
        #                 .collect(groupByUriAndThenCollectLines())
        #                 .forEach(this::printUriWithLines);
        #         writer.close();
        #     }
        @query.find_all_test_case_started.each do |test_case|
          next unless not_passing_or_skipped?(test_case)

          pickle = @query.find_pickle_by(test_case)
          next if pickle.nil?

          file = pickle.uri
          line = pickle.location
          uri_and_line_store[file] << line

          failure_array
        end
      end

      def failure_array
        uri_and_line_store.map do |uri, lines|
          "#{uri}:#{lines.join(':')}"
        end
      end

      def uri_and_line_store
        @uri_and_line_store ||= Hash.new { |hash, key| hash[key] = [] }
      end

      def not_passing_or_skipped?(test_case_started)
        most_severe_test_step_result = @query.find_most_severe_test_step_result_by(test_case_started)
        ![TestStepResultStatus::PASSED, TestStepResultStatus::SKIPPED].include?(most_severe_test_step_result.status)
      end
    end
  end
end
