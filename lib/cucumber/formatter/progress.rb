# frozen_string_literal: true

require 'cucumber/formatter/backtrace_filter'
require 'cucumber/formatter/console'
require 'cucumber/formatter/console_counts'
require 'cucumber/formatter/console_issues'
require 'cucumber/formatter/io'
require 'cucumber/formatter/duration_extractor'
require 'cucumber/formatter/hook_query_visitor'

module Cucumber
  module Formatter
    # The formatter used for <tt>--format progress</tt>
    class Progress
      include Console
      include Io
      attr_reader :runtime
      attr_reader :config

      def initialize(config)
        @config = config
        @io = ensure_io(config.out_stream)
        @previous_step_keyword = nil
        @snippets_input = []
        @total_duration = 0
        @matches = {}
        @pending_step_matches = []
        @failed_results = []
        @passed_test_cases = []
        @counts = ConsoleCounts.new(config)
        @issues = ConsoleIssues.new(config)
        config.on_event :step_activated, &method(:on_step_activated)
        config.on_event :test_case_started, &method(:on_test_case_started)
        config.on_event :test_step_finished, &method(:on_test_step_finished)
        config.on_event :test_case_finished, &method(:on_test_case_finished)
        config.on_event :test_run_finished, &method(:on_test_run_finished)
      end

      def on_step_activated(event)
        @matches[event.test_step.source] = event.step_match
      end

      def on_test_case_started(_event)
        unless @profile_information_printed
          do_print_profile_information(config.profiles) unless config.skip_profile_information? || config.profiles.nil? || config.profiles.empty?
          @profile_information_printed = true
        end
        @previous_step_keyword = nil
      end

      def on_test_step_finished(event)
        test_step = event.test_step
        result = event.result.with_filtered_backtrace(Cucumber::Formatter::BacktraceFilter)
        progress(result.to_sym) if !HookQueryVisitor.new(test_step).hook? || result.failed?

        return if HookQueryVisitor.new(test_step).hook?
        collect_snippet_data(test_step, result)
        @pending_step_matches << @matches[test_step.source] if result.pending?
        @failed_results << result if result.failed?
      end

      def on_test_case_finished(event)
        test_case = event.test_case
        result = event.result.with_filtered_backtrace(Cucumber::Formatter::BacktraceFilter)
        @passed_test_cases << test_case if result.passed?
        @total_duration += DurationExtractor.new(result).result_duration
      end

      def on_test_run_finished(_event)
        @io.puts
        @io.puts
        print_summary
      end

      private

      def print_summary
        print_elements(@pending_step_matches, :pending, 'steps')
        print_elements(@failed_results, :failed, 'steps')
        print_statistics(@total_duration, @config, @counts, @issues)
        print_snippets(config.to_hash)
        print_passing_wip(config, @passed_test_cases)
      end

      CHARS = {
        passed: '.',
        failed: 'F',
        undefined: 'U',
        pending: 'P',
        skipped: '-'
      }.freeze

      def progress(status)
        char = CHARS[status]
        @io.print(format_string(char, status))
        @io.flush
      end

      def table_header_cell?(status)
        status == :skipped_param
      end

      TestCaseData = Struct.new(:name, :location)
    end
  end
end
