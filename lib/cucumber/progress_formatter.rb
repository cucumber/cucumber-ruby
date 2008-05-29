require 'cucumber/pretty_printer'

module Cucumber
  class ProgressFormatter
    include AnsiColours

    def initialize(io)
      @io = (io == STDOUT) ? Kernel : io
      @errors = []
    end

    def step_executed(step)
      case(step.error)
      when Pending
        @io.print yellow('P')
      when NilClass
        @io.print green('.')
      else
        @errors << step.error
        @io.print red('F')
      end
    end
    
    def step_skipped(step)
      @io.print gray('_')
    end

    def dump
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