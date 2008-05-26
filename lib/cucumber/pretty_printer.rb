require 'cucumber/ansi_colours'

module Cucumber
  class PrettyPrinter
    include AnsiColours
    
    def initialize(io)
      @io = (io == STDOUT) ? Kernel : io
      @errors = []
    end
    
    def header_executing(header)
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
    end

    def step_skipped(step)
      @io.puts yellow("    #{step.keyword} ") + blue(step.name)
    end
    
    def dump
      # TODO: stick this in a module, it's duped
      @io.puts
      @errors.each_with_index do |error,n|
        @io.puts
        @io.puts "#{n+1})"
        @io.puts error.message
        @io.puts error.backtrace.join("\n")
      end
    end
  end
end