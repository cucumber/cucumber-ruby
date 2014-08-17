require 'cucumber/formatter/progress'
require 'cucumber/step_definition_light'

module Cucumber
  module Formatter
    class Usage < Progress
      include Console

      class StepDefKey < StepDefinitionLight
        attr_accessor :mean_duration, :status
      end

      def initialize(runtime, path_or_io, options)
        @runtime = runtime
        @io = ensure_io(path_or_io, "usage")
        @options = options
        @stepdef_to_match = Hash.new{|h,stepdef_key| h[stepdef_key] = []}
      end

      def before_features(features)
        print_profile_information
      end

      def before_background(background)
        @outline = false
      end

      def before_feature_element(feature_element)
        case(feature_element)
        when Core::Ast::Scenario
          @outline = false
        when Core::Ast::ScenarioOutline
          @outline = true
          if @options[:expand]
            @in_instantiated_scenario = false
          end
        else
          raise "Bad type: #{feature_element.class}"
        end
      end

      def scenario_name(keyword, name, file_colon_line, source_indent)
        if @outline and @in_instantiated_scenario
          if @new_example_table
            @example_row = 1
            @new_example_table = false
          else
            @example_row += 1
          end
          @example_line = @current_example_rows[@example_row].to_hash['line']
        end
      end

      def before_step(step)
        @step = step
        @start_time = Time.now
      end

      def before_step_result(*args)
        @duration = Time.now - @start_time
      end

      def after_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background, file_colon_line)
        step_definition = step_match.step_definition
        unless step_definition.nil? # nil if it's from a scenario outline
          stepdef_key = StepDefKey.new(step_definition.regexp_source, step_definition.file_colon_line)

          file_colon_line = @step.file_colon_line
          if @outline and @in_instantiated_scenario
            file_colon_line = replace_line_number(@step.file_colon_line, @example_line)
          end

          @stepdef_to_match[stepdef_key] << {
            :keyword => keyword,
            :step_match => step_match,
            :status => status,
            :file_colon_line => file_colon_line,
            :duration => @duration
          }
        end
        super
      end

      def before_examples(examples)
        if @options[:expand]
          @in_instantiated_scenario = true
          @new_example_table = true
          @current_example_rows = to_hash(examples.gherkin_statement)['rows']
        end
      end

      def print_summary(features)
        add_unused_stepdefs
        aggregate_info

        if @options[:dry_run]
          keys = @stepdef_to_match.keys.sort {|a,b| a.regexp_source <=> b.regexp_source}
        else
          keys = @stepdef_to_match.keys.sort {|a,b| a.mean_duration <=> b.mean_duration}.reverse
        end

        keys.each do |stepdef_key|
          print_step_definition(stepdef_key)

          if @stepdef_to_match[stepdef_key].any?
            print_steps(stepdef_key)
          else
            @io.puts("  " + format_string("NOT MATCHED BY ANY STEPS", :failed))
          end
        end
        @io.puts
        super
      end

      def print_step_definition(stepdef_key)
        @io.print format_string(sprintf("%.7f", stepdef_key.mean_duration), :skipped) + " " unless @options[:dry_run]
        @io.print format_string(stepdef_key.regexp_source, stepdef_key.status)
        if @options[:source]
          indent = max_length - stepdef_key.regexp_source.unpack('U*').length
          line_comment = "   # #{stepdef_key.file_colon_line}".indent(indent)
          @io.print(format_string(line_comment, :comment))
        end
        @io.puts
      end

      def print_steps(stepdef_key)
        @stepdef_to_match[stepdef_key].each do |step|
          @io.print "  "
          @io.print format_string(sprintf("%.7f", step[:duration]), :skipped) + " " unless @options[:dry_run]
          @io.print format_step(step[:keyword], step[:step_match], step[:status], nil)
          if @options[:source]
            indent = max_length - (step[:keyword].unpack('U*').length + step[:step_match].format_args.unpack('U*').length)
            line_comment = " # #{step[:file_colon_line]}".indent(indent)
            @io.print(format_string(line_comment, :comment))
          end
          @io.puts
        end
      end

      def max_length
        [max_stepdef_length, max_step_length].compact.max
      end

      def max_stepdef_length
        @stepdef_to_match.keys.flatten.map{|key| key.regexp_source.unpack('U*').length}.max
      end

      def max_step_length
        @stepdef_to_match.values.to_a.flatten.map do |step|
          step[:keyword].unpack('U*').length + step[:step_match].format_args.unpack('U*').length
        end.max
      end

      def aggregate_info
        @stepdef_to_match.each do |key, steps|
          if steps.empty?
            key.status = :skipped
            key.mean_duration = 0
          else
            key.status = worst_status(steps.map{ |step| step[:status] })
            total_duration = steps.inject(0) {|sum, step| step[:duration] + sum}
            key.mean_duration = total_duration / steps.length
          end
        end
      end

      def worst_status(statuses)
        [:passed, :undefined, :pending, :skipped, :failed].find do |status|
          statuses.include?(status)
        end
      end

      def add_unused_stepdefs
        @runtime.unmatched_step_definitions.each do |step_definition|
          stepdef_key = StepDefKey.new(step_definition.regexp_source, step_definition.file_colon_line)
          @stepdef_to_match[stepdef_key] = []
        end
      end

      private

      def replace_line_number(file_colon_line, line)
        file_colon_line.split(':')[0] + ':' + line.to_s
      end

      def to_hash(gherkin_statement)
        if defined?(JRUBY_VERSION)
          gherkin_statement.toMap()
        else
          gherkin_statement.to_hash
        end
      end
    end
  end
end
