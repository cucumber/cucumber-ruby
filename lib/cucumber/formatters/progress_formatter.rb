require 'cucumber/formatters/ansicolor'

module Cucumber
  module Formatters
    class ProgressFormatter
      include ANSIColor

      def initialize(io)
        @io = (io == STDOUT) ? Kernel : io
        @errors             = []
        @pending_scenarios  = []
      end

      def scenario_executing(scenario)
        if scenario.pending?
          @pending_scenarios << scenario
          @io.print pending("P")
        end
      end

      def step_passed(step, regexp, args)
        @io.print passed('.')
      end

      def step_failed(step, regexp, args)
        @errors << step.error
        @io.print failed('F')
      end

      def step_pending(step, regexp, args)
        @pending_scenarios << step.scenario
        @io.print pending('P')
      end

      def step_skipped(step, regexp, args)
        @io.print skipped('_')
      end

      def step_traced(step, regexp, args)
      end

      def dump
        @io.puts pending
        @io.puts "\nPending Scenarios:\n\n" if @pending_scenarios.any?
        @pending_scenarios.uniq.each_with_index do |scenario, n|
          @io.puts "#{n+1}) #{scenario.feature.header.split("\n").first.gsub(/^(Feature|Story):/, '')} (#{scenario.name})"
        end

        @io.puts failed
        @io.puts "\nFailed:" if @errors.any?
        @errors.each_with_index do |error,n|
          @io.puts
          @io.puts "#{n+1})"
          @io.puts error.message
          @io.puts error.backtrace.join("\n")
        end
        @io.print reset
      end
    end
  end
end