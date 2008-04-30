require 'cucumber/pretty_printer'

module Cucumber
  class ProgressFormatter
    def initialize(io)
      @io = io
      @errors = []
    end
    
    def step_executed(step_type, name, line, step, error=nil)
      @io.write(error ? 'F' : '.')
      @errors << [error, step] if error
    end
    
    def dump
      @io.puts
      @errors.each_with_index do |error_step,n|
        e = error_step[0]
        step = error_step[1]
        @io.puts
        @io.puts "#{n+1})"
        @io.puts e.message
        @io.puts e.backtrace.join("\n")
        step.parent.parent.eval(PrettyPrinter.new(@io), :executed)
      end
    end
  end
end