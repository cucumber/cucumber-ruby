require 'cucumber/formatters/ansicolor'

module Cucumber
  module Formatters
    class PrettyFormatter
      include ANSIColor

      INDENT = "\n      "
    
      def initialize(io)
        @io = (io == STDOUT) ? Kernel : io
        @passed = []
        @failed = []
        @pending = []
        @skipped = []
      end
    
      def header_executing(header)
        @io.puts if @feature_newline
        @feature_newline = true
        @io.puts passed(header)
        @io.puts
      end
  
      def scenario_executing(scenario)
        @scenario_failed = false
        if scenario.row?
          @io.print "    |"
        else
          @io.puts passed("  #{Cucumber.language['scenario']}: #{scenario.name}")
        end
      end

      def scenario_executed(scenario)
        @io.puts
        if !scenario.row? && scenario.table_header
          @io.print "    |"
          scenario.table_header.each { |h| @io.print h ; @io.print "|" }
          @io.puts
        elsif scenario.row? && @scenario_failed
          @io.puts
          step_failed(@failed.last) 
        end
      end
      
      def step_executed(step, regexp, args)
        if step.row?
          row_step_executed(step, regexp, args)
        else
          regular_step_executed(step, regexp, args)
        end
      end
      
      def regular_step_executed(step, regexp, args)
        case(step.error)
        when Pending
          @pending << step
          @io.puts pending("    #{step.keyword} #{step.name}")
        when NilClass
          @passed << step
          @io.puts passed("    #{step.keyword} #{step.format(regexp){|param| passed_param(param) << passed}}") 
        else
          @failed << step
          @scenario_failed = true
          @io.puts failed("    #{step.keyword} #{step.format(regexp){|param| failed_param(param) << failed}}") 
          step_failed(step)
        end
      end
      
      def row_step_executed(step, regexp, args)
        case(step.error)
        when Pending
          @pending << step
          args.each{|arg| @io.print pending(arg) ; @io.print "|"}
        when NilClass
          @passed << step
          args.each{|arg| @io.print passed(arg) ; @io.print "|"}
        else
          @failed << step
          @scenario_failed = true
          args.each{|arg| @io.print failed(arg) ; @io.print "|"}
        end
      end

      def step_skipped(step, regexp, args)
        @skipped << step
        if step.row?
          args.each{|arg| @io.print skipped(arg) ; @io.print "|"}
        else
          @io.puts skipped("    #{step.keyword} #{step.format(regexp){|param| skipped_param(param) << skipped}}") 
        end
        step_failed(step) if step.error
      end

      def step_failed(step)
        clean_backtrace = step.error.backtrace.map {|b| b.split("\n") }.flatten.reject do |line|
          line =~ /vendor\/rails/ or line =~ /vendor\/plugins\/cucumber/
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
            snippet = "#{step.actual_keyword} /#{step.name}/ do\nend\n\n"
            prev_keyword = step.keyword
            snippet
          end.compact.uniq
          
          snippets.each do |snippet|
            @io.puts snippet
          end
        end
      end
    end
  end
end
