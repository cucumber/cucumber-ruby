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
      raise "Duplicate pattern: #{regexp.inspect}" if @step_procs.has_key?(regexp)
      proc.extend(CoreExt::CallIn)
      proc.name = key.inspect
      @step_procs[regexp] = proc
    end

    def regexp_and_args_for(step_name)
      candidates = @step_procs.map do |regexp, proc|
        if step_name =~ regexp
          [regexp, $~.captures]
        end
      end.compact
      candidates[0]
    end
    
    def proc_for(regexp)
      @step_procs[regexp]
    end
  end
end