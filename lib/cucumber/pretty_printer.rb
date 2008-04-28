require 'win32console'

module Cucumber

  class PrettyPrinter
    # http://www.bluesock.org/~willg/dev/ansi.html
    ANSI_COLORS = {
      :red     => "\e[31m",
      :green   => "\e[32m",
      :yellow  => "\e[33m",
      :blue    => "\e[34m",
      :magenta => "\e[35m",
    }
    ANSI_NEUTRAL = "\e[0m"

    ANSI_COLORS.each do |c,a|
      define_method(c) do |s|
        "#{a}#{s}#{ANSI_NEUTRAL}"
      end
    end

    def story_executed(name)
      puts yellow("Story: ") + green(name)
    end
  
    def narrative_executed(name)
      puts green(name)
    end
  
    def scenario_executed(name)
      puts
      puts yellow("  Scenario: ") + green(name)
    end
  
    def step_executed(step_type, name, line, error=nil)
      puts yellow("    #{step_type} ") + (error ? red(name) : green(name))
    end
  end
end