# frozen_string_literal: true

require 'cucumber/formatter/io'

module Cucumber
  module Formatter
    class RerunWithMessages < MessageBuilder
      def initialize(config)
        @repository = Cucumber::Repository.new
        @query = Cucumber::Query.new(@repository)
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

          pickle_opt = @query.find_pickle_by(test_case)
          next if pickle_opt.nil?

          pickle = pickle_opt
          uri_and_line = uri_and_line(pickle)
          file = uri_and_line[:uri]
          line = uri_and_line[:line]
          if line
            @failures ||= {}
            @failures[file] ||= []
            @failures[file] << line unless @failures[file].include?(line)
          end
        end
      end

      def not_passing_or_skipped?(test_case_started)
        #     private boolean isNotPassingOrSkipped(TestCaseStarted event) {
        #         return query.findMostSevereTestStepResultBy(event)
        #                 .map(TestStepResult::getStatus)
        #                 .filter(status -> status != TestStepResultStatus.PASSED)
        #                 .filter(status -> status != TestStepResultStatus.SKIPPED)
        #                 .isPresent();
        #     }
        most_severe = @query.find_most_severe_test_step_result_by(test_case_started)
        return false if most_severe.nil?

        status = most_severe.status
        status != :passed && status != :skipped
      end

      def uri_and_line(pickle)
        # private UriAndLine createUriAndLine(Pickle pickle) {
        #         String uri = pickle.getUri();
        #         Long line = query.findLocationOf(pickle).map(Location::getLine).orElse(null);
        #         return new UriAndLine(uri, line);
        #     }
        uri = pickle.uri
        line = @query.find_location_of(pickle)&.line
        { uri: uri, line: line }
      end
    end
  end
end
