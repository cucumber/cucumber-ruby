require 'cucumber/formatter/progress'

module Cucumber
  module Formatter
    class Profile < Progress
      NUMBER_OF_STEP_DEFINITONS_TO_SHOW = 10
      NUMBER_OF_STEP_INVOCATIONS_TO_SHOW = 5

      def initialize(step_mother, io, options)
        super
        @step_definition_durations = Hash.new { |h,step_definition| h[step_definition] = [] }
      end

      def visit_step(step)
        @step_duration = Time.now
        @step = step
        super
      end

      def visit_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        duration = Time.now - @step_duration
        super

        if step_match.step_definition
          description = format_step(keyword, step_match, status, nil)
          @step_definition_durations[step_match.step_definition] << [duration, description, @step.file_colon_line]
        end
      end

      def print_summary(features)
        super
        @io.puts "\n\nTop #{NUMBER_OF_STEP_DEFINITONS_TO_SHOW} average slowest steps with #{NUMBER_OF_STEP_INVOCATIONS_TO_SHOW} slowest matches:\n"

        mean_durations = map_to_mean_durations(@step_definition_durations)
        mean_durations = mean_durations.sort_by do |duration_description_location, step_definition, mean_duration| 
          mean_duration
        end.reverse

        mean_durations[0...NUMBER_OF_STEP_DEFINITONS_TO_SHOW].each do |duration_description_location, step_definition, mean_duration|
          print_step_definition(step_definition, mean_duration)
          duration_description_location = duration_description_location.sort_by do |duration, description, location| 
            duration 
          end.reverse
          print_step_definitions(duration_description_location, step_definition)
        end
      end

      private

      def map_to_mean_durations(step_definition_durations)
        mean_durations = []
        step_definition_durations.each do |step_definition, duration_description_location|
          total_duration = duration_description_location.inject(0) { |sum, step_details| step_details[0] + sum }
          mean_duration = total_duration / duration_description_location.length

          mean_durations << [duration_description_location, step_definition, mean_duration]
        end
        mean_durations
      end

      def print_step_definition(step_definition, mean_duration)
        duration = sprintf("%.7f",  mean_duration)
        @io.puts format_string("#{duration} #{step_definition.backtrace_line}", :failed)
      end

      def print_step_definitions(duration_description_location, step_definition)
        max_length = duration_description_location[0...NUMBER_OF_STEP_INVOCATIONS_TO_SHOW].map{|_, d, _| d.jlength}.max
        duration_description_location[0...NUMBER_OF_STEP_INVOCATIONS_TO_SHOW].each do |duration, description, location|
          @io.print format_string("  #{sprintf("%.7f", duration)}", :pending)
          @io.print "  #{description}"
          @io.print format_string("  # #{location}".indent(max_length - description.jlength), :comment)
          @io.puts
        end
      end
    end
  end
end
