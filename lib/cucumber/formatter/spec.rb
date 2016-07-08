require 'cucumber/formatter/io'
require 'cucumber/core/test/result'

module Cucumber
  module Formatter
    class Spec
      include Io

      def initialize(config)
        @config, @io = config, ensure_io(config.out_stream)
        @test_case_summary = Core::Test::Result::Summary.new

        @config.on_event :test_case_starting do |event|
          print_feature event.test_case
          print_test_case event.test_case
        end

        @config.on_event :test_case_finished do |event|
          print_result event.result
          event.result.describe_to @test_case_summary
        end

        @config.on_event :test_run_finished do |event|
          print_scenario_summary
        end
      end

      private

      def print_feature(test_case)
        feature = test_case.feature
        return if @current_feature == feature
        @io.puts feature
        @current_feature = feature
      end

      def print_test_case(test_case)
        @io.print "  #{test_case.name} "
      end

      def print_result(result)
        @io.puts result
      end

      def print_scenario_summary
        @io.puts
        @io.puts "#{@test_case_summary.total} scenarios"
      end
    end
  end
end

