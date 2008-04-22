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

    def story(name)
      puts yellow("Story: ") + green(name)
    end
  
    def narrative(name)
      puts green(name)
    end
  
    def scenario(name)
      puts
      puts yellow("  Scenario: ") + green(name)
    end
  
    def step(step_type, name, line)
      puts yellow("    #{step_type} ") + green(name)
    end
  end
end