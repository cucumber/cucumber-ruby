# frozen_string_literal: true

require 'cucumber/formatter/io'
require 'cucumber/query'
require 'cucumber/formatter/message_builder'

module Cucumber
  module Formatter
    class NewRerun
      include Formatter::Io

      def initialize(config)
        @io = ensure_io(config.out_stream, config.error_stream)
        @config = config
        @failures = {}
        config.on_event :test_case_finished, &method(:on_test_case_finished)
        config.on_event :test_run_finished, &method(:on_test_run_finished)
      end

      def on_test_case_finished(event)
        test_case, result = *event.attributes
        if @config.strict.strict?(:flaky)
          next if result.ok?(strict: @config.strict)

          add_to_failures(test_case)
        else
          unless @latest_failed_test_case.nil?
            if @latest_failed_test_case != test_case
              add_to_failures(@latest_failed_test_case)
              @latest_failed_test_case = nil
            elsif result.ok?(strict: @config.strict)
              @latest_failed_test_case = nil
            end
          end
          @latest_failed_test_case = test_case unless result.ok?(strict: @config.strict)
        end
      end

      def on_test_run_finished(_event)
        add_to_failures(@latest_failed_test_case) unless @latest_failed_test_case.nil?
        next if @failures.empty?

        @io.print file_failures.join("\n")
      end

      private

      def file_failures
        @failures.map { |file, lines| [file, lines].join(':') }
      end

      def add_to_failures(test_case)
        location = test_case.location
        @failures[location.file] ||= []
        @failures[location.file] << location.lines.max unless @failures[location.file].include?(location.lines.max)
      end
    end
  end
end
