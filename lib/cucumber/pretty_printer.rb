require 'cucumber/ansi_colours'

module Cucumber
  class PrettyPrinter
    include AnsiColours
    
    def initialize(io)
      @io = io
    end
    
    def story_executed(name)
      @io.puts yellow("Story: ") + green(name)
    end
  
    def narrative_executed(name)
      @io.puts green(name)
    end
  
    def scenario_executed(name)
      @io.puts
      @io.puts yellow("  Scenario: ") + green(name)
    end
  
    def step_executed(step_type, name, line, step, error=nil)
      @io.puts yellow("    #{step_type} ") + (error ? red(name) : green(name))
    end
  end
end