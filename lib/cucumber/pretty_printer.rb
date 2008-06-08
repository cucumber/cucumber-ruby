require 'cucumber/ansi_colours'
require 'cucumber/core_ext/string'

module Cucumber
  class PrettyPrinter
    include AnsiColours
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
      @io.puts green("Story: ") + green(header.name)
    end
    
    def narrative_executing(narrative)
      @io.puts green(narrative.text_value)
    end
  
    def scenario_executing(scenario)
      @io.puts
      @io.puts green("  Scenario: ") + green(scenario.name)
    end
  
    def step_executed(step)
      case(step.error)
      when Pending
        @pending << step
        @io.puts yellow("    #{step.keyword} ") + yellow(step.name, " [PENDING]")
      when NilClass
        @passed << step
        @io.puts green("    #{step.keyword} ") + green(step.gzub("\e[7;1;32m%s\e[0;1;32m"))
      else
        @failed << step
        @io.puts red("    #{step.keyword} ") + red(step.gzub("\e[7;1;31m%s\e[0;1;31m"), " [FAILED]")
        @io.puts red("      #{step.error.message.split("\n").join(INDENT)}")
        @io.puts red("      #{step.error.backtrace.join(INDENT)}")
      end
    end

    def step_skipped(step)
      @skipped << step
      @io.puts gray("    #{step.keyword} ") + gray(step.gzub("\e[7;1;30m%s\e[0;1;30m"), " [SKIPPED]")
    end
    
    def dump
      @io.puts
      @io.puts green("#{@passed.length} steps passed") unless @passed.empty?
      @io.puts red("#{@failed.length} steps failed") unless @failed.empty?
      @io.puts yellow("#{@pending.length} steps pending") unless @pending.empty?
      @io.puts gray("#{@skipped.length} steps skipped") unless @skipped.empty?
    end
  end
end