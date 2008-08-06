require 'cucumber/tree/top_down_visitor'
require 'cucumber/core_ext/proc'

module Cucumber
  # A StepMother keeps track of step procs and assigns them
  # to each step when visiting the tree.
  class StepMother < Tree::TopDownVisitor
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
      # Maybe we shouldn't attach the regexp etc to
      # the step? Maybe steps pull them out as needed?
      # Do we then have to attach ourself to the step instead?
      # What would we gain from a pull design?
      @step_procs.each do |regexp, proc|
        if step.respond_to?(:name) && step.name =~ regexp
          step.attach(regexp, proc, $~.captures)
        end
      end
    end
  end
end