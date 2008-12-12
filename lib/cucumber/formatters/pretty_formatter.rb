require 'cucumber/formatters/ansicolor'

module Cucumber
  module Formatters
    class PrettyFormatter
      include ANSIColor

      INDENT = "\n      "

      def initialize(io, step_mother, options={})
        @io = (io == STDOUT) ? Kernel : io
        @options = options
        @step_mother = step_mother
        @pending_scenarios  = []
        @passed             = []
        @failed             = []
        @pending_steps      = []
        @skipped            = []
        @last_executed_was_row = false
        @pending_messages = {}
        @forced_pending_step_count = 0
      end

      def feature_executing(feature)
        @feature = feature
      end

      def header_executing(header)
        @io.puts if @feature_newline
        @feature_newline = true

        header_lines = header.split("\n")
        header_lines.each_with_index do |line, index|
          @io.print line
          if @options[:source] && index==0
            @io.print padding_spaces(@feature)
            @io.print comment("# #{@feature.file}")
          end
          @io.puts
        end
      end

      def scenario_executing(scenario)
        scenario_or_scenario_outline_keyword = scenario.outline? ? Cucumber.language['scenario_outline'] : Cucumber.language['scenario']
        
        @scenario_failed = false
        @io.puts if @last_executed_was_row && !scenario.row?
        if scenario.row?
          @last_executed_was_row = true
          @io.print "    |"
        else
          scenario_text = "#{scenario_or_scenario_outline_keyword}: #{scenario.name}"
          
          if scenario.pending?
            @pending_scenarios << scenario
            @io.print pending("  #{scenario_text}")
          elsif scenario.outline?
            @io.print skipped("  #{scenario_text}")
          else
            @io.print passed("  #{scenario_text}")
          end
          @last_executed_was_row = false

          if @options[:source]
            @io.print padding_spaces(scenario)
            @io.print comment("# #{scenario.file}:#{scenario.line}")
          end
          @io.puts
        end
      end

      def scenario_executed(scenario)
        @io.puts
        if !scenario.row? && scenario.table_header
          @table_column_widths = scenario.table_column_widths
          @current_column = -1
          @io.print "    |"
          print_row(scenario.table_header)
          @io.puts
        elsif scenario.row? && @scenario_failed
          @io.puts
          output_failing_step(@failed.last)
        end
      end

      def step_passed(step, regexp, args)
        if step.row?
          args = step.visible_args if step.outline?
          @passed << step
          print_passed_args(args)
        else
          @passed << step
          @io.print passed("    #{step.keyword} #{step.format(regexp){|param| passed_param(param) << passed}}")
          if @options[:source]
            @io.print padding_spaces(step)
            @io.print source_comment(step)
          end
          @io.puts
        end
      end

      def step_failed(step, regexp, args)
        if step.row?
          args = step.visible_args if step.outline?
          @failed << step
          @scenario_failed = true
          print_failed_args(args)
        else
          @failed << step
          @scenario_failed = true
          @io.print failed("    #{step.keyword} #{step.format(regexp){|param| failed_param(param) << failed}}")
          if @options[:source]
            @io.print padding_spaces(step)
            @io.print source_comment(step)
          end
          @io.puts
          output_failing_step(step)
        end
      end

      def step_skipped(step, regexp, args)
        @skipped << step
        if step.row?
          args = step.visible_args if step.outline?
          print_skipped_args(args)
        else
          @io.print skipped("    #{step.keyword} #{step.format(regexp){|param| skipped_param(param) << skipped}}")
          if @options[:source]
            @io.print padding_spaces(step)
            if step.outline?
              @io.print comment("# #{step.file}:#{step.line}")
            else
              @io.print source_comment(step)
            end
          end
          @io.puts
        end
      end

      def step_pending(step, regexp, args)
        if step.row?
          args = step.visible_args if step.outline?
          @pending_steps << step
          print_pending_args(args)
        else
          @pending_steps << step
          @io.print pending("    #{step.keyword} #{step.name}")
          if @options[:source]
            @io.print padding_spaces(step)
            @io.print comment("# #{step.file}:#{step.line}")
          end
          @io.puts
        end
        if step.forced_to_pending?
          @pending_messages[regexp.inspect] ||= "#{step.keyword} #{regexp.inspect} (#{step.error.message}) #{source_comment(step)}" 
          @forced_pending_step_count += 1
        end
      end

      def step_traced(step, regexp, args)
        @io.print skipped("    #{step.keyword} #{step.format(regexp){|param| skipped_param(param) << skipped}}")
        if @options[:source]
          @io.print padding_spaces(step)
          @io.print comment("# #{step.file}:#{step.line}")
        end
        @io.puts
      end

      def output_failing_step(step)
        @io.puts failed("      #{step.error.message.split("\n").join(INDENT)} (#{step.error.class})")
        @io.puts failed("      #{step.error.cucumber_backtrace.join(INDENT)}")
      end

      def dump
        @io.puts

        print_pending_messages if @pending_messages.any?

        @io.puts pending("#{@pending_scenarios.length} scenarios pending") if @pending_scenarios.any?

        @io.puts passed("#{@passed.length} steps passed")           if @passed.any?
        @io.puts failed("#{@failed.length} steps failed")           if @failed.any?
        @io.puts skipped("#{@skipped.length} steps skipped")        if @skipped.any?
        if @pending_steps.any?
          @io.print pending("#{@pending_steps.length} steps pending") 
          @io.print pending(" (#{number_of_unimplemented_steps} with no step definition)") if number_of_unimplemented_steps > 0
          @io.puts
        end

        @io.print reset

        print_snippets if @options[:snippets]
      end

      def print_pending_messages
        @io.puts "Pending Notes:"
        @pending_messages.each_value do |message|
          @io.puts message
        end
        @io.puts
      end

      def print_snippets
        snippets = @pending_steps
        snippets.delete_if {|snippet| snippet.row? || @step_mother.has_step_definition?(snippet.name)}

        unless snippets.empty?
          @io.puts "\nYou can use these snippets to implement pending steps which have no step definition:\n\n"

          prev_keyword = nil
          snippets = snippets.map do |step|
            snippet = "#{step.actual_keyword} /^#{escape_regexp_characters(step.name)}$/ do\nend\n\n"
            prev_keyword = step.keyword
            snippet
          end.compact.uniq

          snippets.each do |snippet|
            @io.puts snippet
          end
        end
      end

      private

      def number_of_unimplemented_steps
        @pending_steps.length - @forced_pending_step_count
      end

      def escape_regexp_characters(string)
        Regexp.escape(string).gsub('\ ', ' ').gsub('/', '\/') unless string.nil?
      end
      
      def source_comment(step)
        _, _, proc = step.regexp_args_proc(@step_mother)
        comment(proc.to_comment_line)
      end

      def padding_spaces(tree_item)
        " " * tree_item.padding_length
      end

      def next_column_index
        @current_column ||= -1
        @current_column += 1
        @current_column = 0 if @current_column >= @table_column_widths.size
        @current_column
      end

      def print_row(row_args, &colorize_proc)
        colorize_proc = Proc.new{|row_element| row_element} unless colorize_proc

        row_args.each do |row_arg|
          column_index = next_column_index
          @io.print colorize_proc[row_arg.ljust(@table_column_widths[column_index])]
          @io.print "|"
        end
      end

      def print_passed_args(args)
        print_row(args) {|arg| passed(arg)}
      end

      def print_skipped_args(args)
        print_row(args) {|arg| skipped(arg)}
      end

      def print_failed_args(args)
        print_row(args) {|arg| failed(arg)}
      end

      def print_pending_args(args)
        print_row(args) {|arg| pending(arg)}
      end
    end
  end
end
