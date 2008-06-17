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
        # TODO: i18n Story
        @io.puts passed("Story: #{header}")
      end
    
      def narrative_executing(narrative)
        @io.puts passed(narrative)
      end
  
      def scenario_executing(scenario)
        @io.puts
        # TODO: i18n Secnario
        @io.puts passed("  Scenario: #{scenario.name}")
      end
  
      def step_executed(step)
        case(step.error)
        when Pending
          @pending << step
          @io.puts pending("    #{step.keyword} #{step.name}")
        when NilClass
          @passed << step
          @io.puts passed("    #{step.keyword} #{step.gzub{|p| parameter(p) << passed}}") 
        else
          @failed << step
          @io.puts failed("    #{step.keyword} #{step.gzub{|p| parameter(p) << failed}}") 
          @io.puts failed("      #{step.error.message.split("\n").join(INDENT)}")
          @io.puts failed("      #{step.error.backtrace.join(INDENT)}")
        end
      end

      def step_skipped(step)
        @skipped << step
        @io.puts skipped("    #{step.keyword} #{step.gzub{|p| parameter(p) << skipped}}") 
      end
    
      def dump
        @io.puts
        @io.puts passed("#{@passed.length} steps passed") unless @passed.empty?
        @io.puts failed("#{@failed.length} steps failed") unless @failed.empty?
        @io.puts pending("#{@pending.length} steps pending") unless @pending.empty?
        @io.puts skipped("#{@skipped.length} steps skipped") unless @skipped.empty?
        @io.print reset
      end
    end
  end
end