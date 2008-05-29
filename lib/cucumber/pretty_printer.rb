require 'cucumber/ansi_colours'

module Cucumber
  class PrettyPrinter
    include AnsiColours
    
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
      @io.puts yellow("Story: ") + green(header.name)
    end
    
    def narrative_executing(narrative)
      @io.puts green(narrative.text_value)
    end
  
    def scenario_executing(scenario)
      @io.puts
      @io.puts yellow("  Scenario: ") + green(scenario.name)
    end
  
    def step_executed(step)
      case(step.error)
      when Pending
        @pending << step
        @io.puts yellow("    #{step.keyword} ") + yellow(step.name, " [PENDING]")
      when NilClass
        @passed << step
        @io.puts yellow("    #{step.keyword} ") + green(step.name)
      else
        @failed << step
        @io.puts yellow("    #{step.keyword} ") + red(step.name, " [FAILED]")
        @io.puts    red("      #{step.error.message}")
        @io.puts    red("      #{step.error.backtrace.join("\n      ")}")
      end
    end

    def step_skipped(step)
      @skipped << step
      @io.puts yellow("    #{step.keyword} ") + gray(step.name, " [SKIPPED]")
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