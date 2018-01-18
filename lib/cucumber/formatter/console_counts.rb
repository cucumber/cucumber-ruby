require 'cucumber/formatter/console'

module Cucumber
  module Formatter
    class ConsoleCounts
      include Console

      def initialize(config)
        @summary = Core::Report::Summary.new(config.event_bus)
      end

      def to_s
        [
          [scenario_count, status_counts(@summary.test_cases)].compact.join(' '),
          [step_count, status_counts(@summary.test_steps)].compact.join(' ')
        ].join("\n")
      end

      private

      def scenario_count
        count = @summary.test_cases.total
        "#{count} scenario" + (count == 1 ? '' : 's')
      end

      def step_count
        count = @summary.test_steps.total
        "#{count} step" + (count == 1 ? '' : 's')
      end

      def status_counts(summary)
        counts = Core::Test::Result::TYPES.map do |status|
          count = summary.total(status)
          [status, count]
        end.select do |status, count|
          count > 0
        end.map do |status, count|
          format_string("#{count} #{status}", status)
        end
        "(#{counts.join(", ")})" if counts.any?
      end
    end
  end
end
