require 'cucumber/formatter/progress'

module Cucumber
  module Formatter
    class Profile < Progress
      NUMBER_OF_STEP_DEFINITONS_TO_SHOW = 10
      NUMBER_OF_STEP_INVOCATIONS_TO_SHOW = 5

      def initialize(step_mother, io, options)
        super
        @step_definition_times = Hash.new { |h,step_definition| h[step_definition] = [] }
      end

      def visit_step(step)
        @step_time = Time.now
        super
      end

      #def step_passed(step, regexp, args)
      def visit_step_name(gwt, step_name, status, step_invocation, comment_padding)
        execution_time = Time.now - @step_time
        super

        if step_invocation # nil for outline steps
          description = format_step(gwt, step_name, status, step_invocation, comment_padding, true)
          @step_definition_times[step_invocation.step_definition] << [description, execution_time]
        end
      end

      def print_summary(io, features)
        super
        @io.puts "\n\nTop #{NUMBER_OF_STEP_DEFINITONS_TO_SHOW} average slowest steps with #{NUMBER_OF_STEP_INVOCATIONS_TO_SHOW} slowest matches:\n"

        mean_times = map_to_mean_times(@step_definition_times)
        mean_times = mean_times.sort_by do |description_and_execution_time, step_definition, mean_execution_time| 
          mean_execution_time
        end.reverse

        mean_times[0...NUMBER_OF_STEP_DEFINITONS_TO_SHOW].each do |description_and_execution_time, step_definition, mean_execution_time|
          print_step_definition(description_and_execution_time, step_definition, mean_execution_time)
          description_and_execution_time = description_and_execution_time.sort_by do |description, execution_time| 
            execution_time 
          end.reverse
          print_step_invocations(description_and_execution_time, step_definition)
        end
      end

      private
      def map_to_mean_times(step_definition_times)
        mean_times = []
        step_definition_times.each do |step_definition, description_and_execution_time|
          total_execution_time = description_and_execution_time.inject(0) { |sum, step_details| step_details[1] + sum }
          mean_execution_time = total_execution_time / description_and_execution_time.length

          mean_times << [description_and_execution_time, step_definition, mean_execution_time]
        end
        mean_times
      end

      def print_step_definition(description_and_execution_time, step_definition, mean_execution_time)
        unless description_and_execution_time.empty?
          definition_comment, _ = description_and_execution_time.first
          @io.print format_string(sprintf("%.7f",  mean_execution_time), :failed)
          @io.print "  #{step_definition.to_backtrace_line}"
          @io.puts
        end
      end

      def print_step_invocations(description_and_execution_time, step_definition)
        description_and_execution_time[0...NUMBER_OF_STEP_INVOCATIONS_TO_SHOW].each do |description, execution_time|
          @io.print "  #{format_string(sprintf("%.7f", execution_time), :pending)}"
          @io.print "  #{description}"
          @io.puts
        end
      end

      def source(step)
        _, _, proc = step.regexp_args_proc(@step_mother)
        proc.to_comment_line
      end

    end
  end
end
