require 'cucumber/formatters/ansicolor'

module Cucumber
  module Formatters
    class ProgressFormatter
      include ANSIColor

      def initialize(io)
        @io = (io == STDOUT) ? Kernel : io
        @errors = []
      end
      
      def step_passed(step, regexp, args)
        @io.print passed('.')
      end
      
      def step_failed(step, regexp, args)
        @errors << step.error
        @io.print failed('F')
      end
      
      def step_pending(step, regexp, args)
        @io.print pending('P')
      end
    
      def step_skipped(step, regexp, args)
        @io.print skipped('_')
      end

      def dump
        @io.puts failed
        @errors.each_with_index do |error,n|
          @io.puts
          @io.puts "#{n+1})"
          @io.puts error.message
          @io.puts error.backtrace.join("\n")
        end
        @io.print reset
      end
    end
  end
end