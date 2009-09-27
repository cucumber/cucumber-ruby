require 'cucumber/formatter/console'

module Cucumber
  module Formatter
    class Stats
      include Console

      def initialize(step_mother, io, options)
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
        
        stepdef_key = [ # Would be nicer with a Hash, but they can't be used as keys on Ruby 1.8
          step_match.step_definition.regexp_source, 
          step_match.step_definition.file_colon_line
        ]
        if step_match.name.nil? # nil if it's from a scenario outline
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
        stepdef_keys = @stepdef_to_match.keys
        
        max_stepdef_length = stepdef_keys.map{|key| key[0].jlength}.max
        max_stepdef_length += 2 if max_stepdef_length
        max_step_length    = @stepdef_to_match.values.flatten.map do |step|
          step ? step[:keyword].jlength + step[:step_match].format_args.jlength : nil
        end.compact.max
        max_length = [max_stepdef_length, max_step_length].compact.max
        
        stepdef_keys.each do |stepdef_key|
          @io.print format_string(sprintf("%.7f", 0.5), :skipped) + " " unless @options[:dry_run]
          @io.print format_string(stepdef_key[0], :failed)
          if @options[:source]
            indent = max_length - stepdef_key[0].jlength
            line_comment = "    # #{stepdef_key[1]}".indent(indent)
            @io.print(format_string(line_comment, :comment))
          end
          @io.puts

          @stepdef_to_match[stepdef_key].each do |step|
            next if step.nil?
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
        end
      end
      
      def add_unused_stepdefs
        stepdef_key = ['/JALLA MY IOKE REGEXP/', 'foo/kl.ioke:99']
        @stepdef_to_match[stepdef_key] << nil
      end
    end
  end
end