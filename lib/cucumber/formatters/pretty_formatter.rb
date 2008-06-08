require 'term/ansicolor'
require 'cucumber/core_ext/string'

module Cucumber
  module Formatters
    class PrettyFormatter
      include Term::ANSIColor
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
        @io.puts green("Story: #{header.name}")
      end
    
      def narrative_executing(narrative)
        @io.puts green(narrative.text_value)
      end
  
      def scenario_executing(scenario)
        @io.puts
        @io.puts green("  Scenario: #{scenario.name}")
      end
  
      def step_executed(step)
        case(step.error)
        when Pending
          @pending << step
          @io.puts yellow("    #{step.keyword} #{step.name}")
        when NilClass
          @passed << step
          @io.puts green("    #{step.keyword} #{step.gzub{|p| negative(p) << green}}") 
        else
          @failed << step
          @io.puts red("    #{step.keyword} #{step.gzub{|p| negative(p) << red}}") 
          @io.puts red("      #{step.error.message.split("\n").join(INDENT)}")
          @io.puts red("      #{step.error.backtrace.join(INDENT)}")
        end
      end

      def step_skipped(step)
        @skipped << step
        @io.puts black("    #{step.keyword} #{step.gzub{|p| negative(p) << black}}") 
      end
    
      def dump
        @io.puts
        @io.puts green("#{@passed.length} steps passed") unless @passed.empty?
        @io.puts red("#{@failed.length} steps failed") unless @failed.empty?
        @io.puts yellow("#{@pending.length} steps pending") unless @pending.empty?
        @io.puts black("#{@skipped.length} steps skipped") unless @skipped.empty?
      end
    end
  end
end