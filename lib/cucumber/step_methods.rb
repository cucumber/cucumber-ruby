require 'cucumber/step_mother'

module Cucumber
  module StepMethods  
    def World(&proc)
      $executor.register_world_proc(&proc)
    end

    def Before(&proc)
      $executor.register_before_proc(&proc)
    end
    
    def After(&proc)
      $executor.register_after_proc(&proc)
    end

    def Given(key, &proc)
      step_mother.register_step_proc(key, &proc)
    end

    def When(key, &proc)
      step_mother.register_step_proc(key, &proc)
    end

    def Then(key, &proc)
      step_mother.register_step_proc(key, &proc)
    end
    
    # Simple workaround for old skool steps
    def steps_for(*_)
      STDERR.puts "WARNING: In Cucumber the steps_for method is obsolete"
      yield
    end
    
    def step_mother #:nodoc:
      @step_mother ||= StepMother.new
    end
  end
end
