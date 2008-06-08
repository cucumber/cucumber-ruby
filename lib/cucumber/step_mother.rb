require 'cucumber/parser/top_down_visitor'
require 'cucumber/core_ext/proc'

module Cucumber
  class StepMother < Parser::TopDownVisitor
    def initialize
      @step_procs = {}
    end

    def register_step_proc(key, &proc)
      regexp = case(key)
      when String
        Regexp.new("^#{key}$") # TODO: replace $variable with (.*)
      when Regexp
        key
      else
        raise "Step patterns must be Regexp or String, but was: #{key.inspect}"
      end
      proc.extend(CoreExt::CallIn)
      proc.name = key.inspect
      @step_procs[regexp] = proc
    end
    
    def visit_step(step)
      @step_procs.each do |regexp, proc|
        if step.name =~ regexp
          step.attach(regexp, proc, $~.captures)
        end
      end
    end
  end
end