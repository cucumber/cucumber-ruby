require 'cucumber/formatter/console'

module Cucumber
  module Formatter
    class Stats
      include Console

      class StepDefKey
        attr_reader :regexp_source, :file_colon_line
        
        def initialize(regexp_source, file_colon_line)
          @regexp_source, @file_colon_line = regexp_source, file_colon_line
        end
        
        def eql?(step_def_key)
          regexp_source.eql?(step_def_key) && file_colon_line.eql?(file_colon_line)
        end
      end

      def initialize(step_mother, io, options)
        @step_mother = step_mother
        @io = io
        @options = options
        @stepdef_to_match = Hash.new{|h,stepdef_key| h[stepdef_key] = []}
      end

      def before_step(step)
        @step = step
      end

      def before_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        @step_duration = Time.now
      end

      def after_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        duration = Time.now - @step_duration
        if step_match.name.nil? # nil if it's from a scenario outline
          stepdef_key = StepDefKey.new(step_match.step_definition.regexp_source, step_match.step_definition.file_colon_line)

          @stepdef_to_match[stepdef_key] << {
            :keyword => keyword, 
            :step_match => step_match, 
            :status => status, 
            :file_colon_line => @step.file_colon_line,
            :duration => duration
          }
        end
      end

      def after_features(features)
        add_unused_stepdefs
        
        @stepdef_to_match.keys.each do |stepdef_key|
          @io.print format_string(sprintf("%.7f", 0.5), :skipped) + " " unless @options[:dry_run]
          @io.print format_string(stepdef_key.regexp_source, :failed)
          if @options[:source]
            indent = max_length - stepdef_key.regexp_source.jlength
            line_comment = "    # #{stepdef_key.file_colon_line}".indent(indent)
            @io.print(format_string(line_comment, :comment))
          end
          @io.puts

          if @stepdef_to_match[stepdef_key].any?
            @stepdef_to_match[stepdef_key].each do |step|
              @io.print "  "
              @io.print format_string(sprintf("%.7f", step[:duration]), :skipped) + " " unless @options[:dry_run]
              @io.print format_step(step[:keyword], step[:step_match], step[:status], nil)
              if @options[:source]
                indent = max_length - (step[:keyword].jlength + step[:step_match].format_args.jlength)
                line_comment = " # #{step[:file_colon_line]}".indent(indent)
                @io.print(format_string(line_comment, :comment))
              end
              @io.puts
            end
          else
            @io.puts("  " + format_string("NOT MATCHED BY ANY STEPS", :failed))
          end
        end
      end

      def max_length
        max_stepdef_length = @stepdef_to_match.keys.flatten.map{|key| key.regexp_source.jlength}.max
        max_stepdef_length += 2 if max_stepdef_length
        max_step_length    = @stepdef_to_match.values.flatten.map do |step|
          step[:keyword].jlength + step[:step_match].format_args.jlength
        end.max
        [max_stepdef_length, max_step_length].compact.max
      end

      def add_unused_stepdefs
        @step_mother.unmatched_step_definitions.each do |step_definition|
          stepdef_key = StepDefKey.new(step_definition.regexp_source, step_definition.file_colon_line)
          @stepdef_to_match[stepdef_key] = []
        end
      end
    end
  end
end