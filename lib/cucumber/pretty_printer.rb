require 'cucumber/ansi_colours'

module Cucumber
  class PrettyPrinter
    include AnsiColours
    
    def initialize(io)
      @io = (io == STDOUT) ? Kernel : io
      @errors = []
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
      out = case(step.error)
      when Pending
        yellow(step.name)
      when NilClass
        green(step.name)
      else
        @errors << step.error
        red(step.name)
      end
      @io.puts yellow("    #{step.keyword} ") + out
      
      if step.error
        @io.puts red("      #{step.error.message}")
        @io.puts red("      #{step.error.backtrace.join("\n      ")}")
      end
    end

    def step_skipped(step)
      @io.puts yellow("    #{step.keyword} ") + gray(step.name)
    end
    
    def dump
    end
  end
end