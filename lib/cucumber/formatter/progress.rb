require 'cucumber/formatter/console'

module Cucumber
  module Formatter
    class Progress < Ast::Visitor
      include Console

      def initialize(step_mother, io)
        super(step_mother)
        @io = (io == STDOUT) ? Kernel : io
        @errors             = []
        @pending_scenarios  = []
      end

      def visit_feature_element(feature_element)
        @io.print(pending("S")) if feature_element.pending?
        super
      end

      def visit_step_name(gwt, step_name, status, step_invocation, comment_padding)
        @io.print(format_string('.', status)) unless status == :outline
      end

      def visit_table_cell_value(value, width, status)
        @io.print(format_string('.', status)) unless status == :thead
      end



      def scenario_executing(scenario)
        if scenario.pending?
          @pending_scenarios << scenario
          @io.print pending("P")
        end
      end

      def step_passed(step, regexp, args)
        @io.print format_string('.', :passed)
      end

      def step_failed(step, regexp, args)
        @errors << step.error
        @io.print format_string('F', :failed)
      end

      def step_pending(step, regexp, args)
        @pending_scenarios << step.scenario
        @io.print format_string('P', :pending)
      end

      def step_skipped(step, regexp, args)
        @io.print format_string('X', :skipped)
      end

      def step_traced(step, regexp, args)
      end

      def dump
        @io.puts
        @io.puts format_string("\nPending Scenarios:\n\n", :pending) if @pending_scenarios.any?
        @pending_scenarios.uniq.each_with_index do |scenario, n|
          @io.puts "#{n+1}) #{scenario.feature.header.split("\n").first.gsub(/^(Feature|Story):/, '')} (#{scenario.name})"
        end

        @io.puts
        @io.puts format_string("\nFailed:", :failed) if @errors.any?
        @errors.each_with_index do |error,n|
          @io.puts
          @io.puts format_string("#{n+1})", :failed)
          @io.puts format_string(error.message, :failed)
          @io.puts format_string(error.backtrace.join("\n"), :failed)
        end
      end
    end
  end
end