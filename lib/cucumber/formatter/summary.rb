require 'cucumber/formatter/io'
require 'cucumber/formatter/console'
require 'cucumber/formatter/console_counts'
require 'cucumber/core/test/result'

module Cucumber
  module Formatter

    # Summary formatter, outputting only feature / scenario titles
    class Summary
      include Io
      include Console

      def initialize(config)
        @config, @io = config, ensure_io(config.out_stream)
        @counts = ConsoleCounts.new(@config)

        @config.on_event :test_case_starting do |event|
          print_feature event.test_case
          print_test_case event.test_case
        end

        @config.on_event :test_case_finished do |event|
          print_result event.result
        end

        @config.on_event :test_run_finished do |event|
          print_counts
        end
      end

      private

      def print_feature(test_case)
        feature = test_case.feature
        return if @current_feature == feature
        @io.puts unless @current_feature.nil?
        @io.puts feature
        @current_feature = feature
      end

      def print_test_case(test_case)
        @io.print "  #{test_case.name} "
      end

      def print_result(result)
        @io.puts format_string(result, result.to_sym)
      end

      def print_counts
        @io.puts
        @io.puts @counts.to_s
      end
    end
  end
end

