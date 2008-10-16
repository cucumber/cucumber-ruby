require 'cucumber/formatters/ansicolor'

module Cucumber
  module Formatters
    class PrettyFormatter
      include ANSIColor

      INDENT = "\n      "
      BACKTRACE_FILTER_PATTERNS = [/vendor\/rails/, /vendor\/plugins\/cucumber/, /spec\/expectations/, /spec\/matchers/]
    
      def initialize(io, step_mother, options={})
        @io = (io == STDOUT) ? Kernel : io
        @options = options
        @step_mother = step_mother
        @passed = []
        @failed = []
        @pending = []
        @skipped = []
      end
 
      def visit_feature(feature)
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
        @scenario_failed = false
        if scenario.row?
          @io.print "    |"
        else
          @io.print passed("  #{Cucumber.language['scenario']}: #{scenario.name}")
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
          @passed << step
	  print_passed_row(args)
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
          @failed << step
          @scenario_failed = true
          print_failed_row(args)
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
          print_skipped_row(args)
        else
          @io.print skipped("    #{step.keyword} #{step.format(regexp){|param| skipped_param(param) << skipped}}") 
          if @options[:source]
            @io.print padding_spaces(step)
            @io.print source_comment(step) 
          end
          @io.puts
        end
      end

      def step_pending(step, regexp, args)
        if step.row?
          @pending << step
          print_pending_row(args)
        else
          @pending << step
          @io.print pending("    #{step.keyword} #{step.name}")
          if @options[:source]
            @io.print padding_spaces(step)
            @io.print comment("# #{step.file}:#{step.line}")
          end
          @io.puts
        end
      end
      
      def output_failing_step(step)
        backtrace = step.error.backtrace || []
        clean_backtrace = backtrace.map {|b| b.split("\n") }.flatten.reject do |line|
          BACKTRACE_FILTER_PATTERNS.detect{|p| line =~ p}
        end.map { |line| line.strip }
        @io.puts failed("      #{step.error.message.split("\n").join(INDENT)} (#{step.error.class})")
        @io.puts failed("      #{clean_backtrace.join(INDENT)}")
      end

      def dump
        @io.puts
        @io.puts passed("#{@passed.length} steps passed") unless @passed.empty?
        @io.puts failed("#{@failed.length} steps failed") unless @failed.empty?
        @io.puts skipped("#{@skipped.length} steps skipped") unless @skipped.empty?
        @io.puts pending("#{@pending.length} steps pending") unless @pending.empty?
        @io.print reset
        print_snippets
      end
            
      def print_snippets
        unless @pending.empty?
          @io.puts "\nYou can use these snippets to implement pending steps:\n\n"
          
          prev_keyword = nil
          snippets = @pending.map do |step|
            next if step.row?
            snippet = "#{step.actual_keyword} /^#{step.name}$/ do\nend\n\n"
            prev_keyword = step.keyword
            snippet
          end.compact.uniq
          
          snippets.each do |snippet|
            @io.puts snippet
          end
        end
      end
      
      private

      def source_comment(step)
        _, _, proc = step.regexp_args_proc(@step_mother)
        comment(proc.to_comment_line)
      end
      
      def padding_spaces(tree_item)
        " " * tree_item.padding_length
      end

      def print_row row_elements, &colorize_proc
        colorize_proc = Proc.new{|row_element| row_element} unless colorize_proc

        @largest_elements ||= [0]*row_elements.size

        row_elements.each_with_index do |row_element, i|
          @largest_elements[i] = row_element.size if @largest_elements[i] < row_element.size
          @io.print colorize_proc[row_element.ljust(@largest_elements[i])]
          @io.print "|"
        end
      end

      def print_passed_row row_elements
	print_row(row_elements) {|row_element| passed(row_element)}      
      end
      
      def print_skipped_row row_elements
	print_row(row_elements) {|row_element| skipped(row_element)}      
      end

      def print_failed_row row_elements
	print_row(row_elements) {|row_element| failed(row_element)}      
      end

      def print_pending_row row_elements
	print_row(row_elements) {|row_element| pending(row_element)}      
      end
    end
  end
end
