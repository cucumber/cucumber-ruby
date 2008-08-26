require 'cucumber/tree/top_down_visitor'
require 'cucumber/core_ext/proc'

module Cucumber
  class StepMother
    PENDING = lambda do |*_| 
      raise Pending
    end
    PENDING.extend(CoreExt::CallIn)
    PENDING.name = "PENDING"

    def initialize
      @step_procs = Hash.new(PENDING)
    end

    def register_step_proc(key, &proc)
      regexp = case(key)
      when String
        # Replace the $foo and $bar style parameters
        pattern = key.gsub(/\$\w+/, '(.*)')
        Regexp.new("^#{pattern}$")
      when Regexp
        key
      else
        raise "Step patterns must be Regexp or String, but was: #{key.inspect}"
      end
      proc.extend(CoreExt::CallIn)
      proc.name = key.inspect

      if @step_procs.has_key?(regexp)
        first_proc = @step_procs[regexp]
        message = %{Duplicate step definitions:

#{first_proc.backtrace_line}
#{proc.backtrace_line}
}
        raise message
      end

      @step_procs[regexp] = proc
    end

    def regexp_args_proc(step_name)
      candidates = @step_procs.map do |regexp, proc|
        if step_name =~ regexp
          [regexp, $~.captures, proc]
        end
      end.compact
      
      if candidates.length > 1
        message = %{Ambiguos step resolution for #{step_name.inspect}:

#{candidates.map{|regexp, args, proc| proc.backtrace_line}.join("\n")}
}
        raise message
      end
      
      candidates[0]
    end
    
    def proc_for(regexp)
      @step_procs[regexp]
    end
  end
end