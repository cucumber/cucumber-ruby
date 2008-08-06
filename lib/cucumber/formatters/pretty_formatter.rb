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
        @io.puts if @story_newline
        @story_newline = true
        @io.puts passed(header)
      end
    
      def narrative_executing(narrative)
        @io.puts passed(narrative)
      end
  
      def scenario_executing(scenario)
        @scenario_failed = false
        @io.puts
        if scenario.row?
          @io.print "    |"
        else
          # TODO: i18n Secnario
          @io.puts passed("  Scenario: #{scenario.name}")
        end
      end

      def scenario_executed(scenario)
        if scenario.row? && @scenario_failed
          @io.puts
          step_failed(@failed.last) 
        end
      end

      def step_executed(step)
        if step.row?
          row_step_executed(step)
        else
          regular_step_executed(step)
        end
      end
      
      def regular_step_executed(step)
        case(step.error)
        when Pending
          @pending << step
          @io.puts pending("    #{step.keyword} #{step.name}")
        when NilClass
          @passed << step
          @io.puts passed("    #{step.keyword} #{step.gzub{|param| passed_param(param) << passed}}") 
        else
          @failed << step
          @scenario_failed = true
          @io.puts failed("    #{step.keyword} #{step.gzub{|param| failed_param(param) << failed}}") 
          step_failed(step)
        end
      end
      
      def step_failed(step)
        @io.puts failed("      #{step.error.message.split("\n").join(INDENT)} (#{step.error.class})")
        @io.puts failed("      #{step.error.backtrace.join(INDENT)}")
      end

      def row_step_executed(step)
        case(step.error)
        when Pending
          @pending << step
          step.args.each { |arg| @io.print pending(arg) ; @io.print "|" }
        when NilClass
          @passed << step
          step.args.each { |arg| @io.print passed(arg) ; @io.print "|" }
        else
          @failed << step
          @scenario_failed = true
          step.args.each { |arg| @io.print failed(arg) ; @io.print "|" }
        end
      end

      def step_skipped(step)
        @skipped << step
        if step.row?
          step.args.each { |arg| @io.print skipped(arg) ; @io.print "|" }
        else
          @io.puts skipped("    #{step.keyword} #{step.gzub{|param| skipped_param(param) << skipped}}") 
        end
      end
    
      def dump
        @io.puts
        @io.puts passed("#{@passed.length} steps passed") unless @passed.empty?
        @io.puts failed("#{@failed.length} steps failed") unless @failed.empty?
        @io.puts skipped("#{@skipped.length} steps skipped") unless @skipped.empty?
        @io.puts pending("#{@pending.length} steps pending") unless @pending.empty?

        unless @pending.empty?
          @io.puts "\nYou can use these snippets to implement pending steps:\n\n"
          
          @pending.each do |step|
            @io.puts "#{step.keyword} /#{step.name}/ do\nend\n\n" unless step.row?
          end
        end

        @io.print reset
      end
    end
  end
end