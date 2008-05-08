require 'cucumber/ansi_colours'

module Cucumber
  class PrettyPrinter
    include AnsiColours
    
    def initialize(io)
      @io = io
    end
    
    def visit_header(header)
      @io.puts yellow("Story: ") + green(header.name)
    end
    
    def visit_narrative(narrative)
      @io.puts green(narrative.text_value)
    end
  
    def visit_scenario(scenario)
      @io.puts
      @io.puts yellow("  Scenario: ") + green(scenario.name)
      scenario.accept(self)
    end
  
    def visit_step(step)
      @io.puts yellow("    #{step.keyword} ") + (step.error ? red(step.name) : green(step.name))
    end
  end
end