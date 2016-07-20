require 'cucumber/formatter/console'

module Cucumber
  module Formatter
    class ConsoleCounts
      include Console

      def initialize(config)
        @test_case_summary = Core::Test::Result::Summary.new
        @test_step_summary = Core::Test::Result::Summary.new

        config.on_event :test_case_finished do |event|
          event.result.describe_to @test_case_summary
        end

        config.on_event :test_step_finished do |event|
          event.result.describe_to @test_step_summary if from_gherkin?(event.test_step)
        end
      end

      def to_s
        [
          [scenario_count, status_counts(@test_case_summary)].compact.join(" "),
          [step_count, status_counts(@test_step_summary)].compact.join(" ")
        ].join("\n")
      end

      private

      def from_gherkin?(test_step)
        test_step.source.last.location.file.match(/\.feature$/)
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
        counts = [:failed, :skipped, :undefined, :pending, :passed].map { |status|
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
