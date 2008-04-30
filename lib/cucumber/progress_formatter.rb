module Cucumber
  class ProgressFormatter
    def initialize(io)
      @io = io
      @errors = []
    end
    
    def step_executed(step_type, name, line, error=nil)
      @io.write(error ? 'F' : '.')
      @errors << error if error
    end
    
    def dump
      @io.puts
      @errors.each_with_index do |e,n|
        @io.puts
        @io.puts "#{n+1})"
        @io.puts e.message
        @io.puts e.backtrace.join("\n")
      end
    end
  end
end