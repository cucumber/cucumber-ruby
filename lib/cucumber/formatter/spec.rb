require 'cucumber/formatter/io'
require 'cucumber/core/test/result'

module Cucumber
  module Formatter
    class Spec
      include Io
      include Console

      def initialize(config)
        @config, @io = config, ensure_io(config.out_stream)
        @test_case_summary = Core::Test::Result::Summary.new
        @test_step_summary = Core::Test::Result::Summary.new

        @config.on_event :test_case_starting do |event|
          print_feature event.test_case
          print_test_case event.test_case
        end

        @config.on_event :test_case_finished do |event|
          print_result event.result
          event.result.describe_to @test_case_summary
        end

        @config.on_event :test_step_finished do |event|
          event.result.describe_to @test_step_summary if from_gherkin?(event.test_step)
        end

        @config.on_event :test_run_finished do |event|
          print_scenario_summary
        end
      end

      private

      def from_gherkin?(test_step)
        test_step.source.last.location.file.match(/\.feature$/)
      end

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

      def print_scenario_summary
        @io.puts
        @io.puts [scenario_count, status_counts(@test_case_summary)].join(" ")
        @io.puts [step_count, status_counts(@test_step_summary)].join(" ")
      end

      def scenario_count
        count = @test_case_summary.total
        "#{count} scenario" + (count == 1 ? "" : "s")
      end

      def step_count
        count = @test_step_summary.total
        "#{count} step" + (count == 1 ? "" : "s")
      end

      def status_counts(summary)
        counts = [:passed, :failed, :undefined, :pending].map { |status|
          count = summary.total(status)
          [status, count]
        }.select { |status, count|
          count > 0
        }.map { |status, count|
          format_string("#{count} #{status}", status)
        }
        "(#{counts.join(", ")})" if counts.any?
      end
    end
  end
end

