# frozen_string_literal: true

require 'cucumber/formatter/io'

module Cucumber
  module Formatter
    class Rerun
      include Formatter::Io

      def initialize(config)
        @io = ensure_io(config.out_stream)
        @config = config
        @failures = {}
        config.on_event :test_case_finished do |event|
          test_case, result = *event.attributes
          next if result.ok?(@config.strict)
          @failures[test_case.location.file] ||= []
          @failures[test_case.location.file] << test_case.location.line
        end
        config.on_event :test_run_finished do
          next if @failures.empty?
          @io.print file_failures.join("\n")
        end
      end

      private

      def file_failures
        @failures.map { |file, lines| [file, lines].join(':') }
      end
    end
  end
end
