module Cucumber
  module StepMethods
    def Before(&proc)
      $executor.register_before_proc(&proc)
    end
    
    def After(&proc)
      $executor.register_after_proc(&proc)
    end

    def Given(key, &proc)
      $executor.register_step_proc(key, &proc)
    end

    def When(key, &proc)
      $executor.register_step_proc(key, &proc)
    end

    def Then(key, &proc)
      $executor.register_step_proc(key, &proc)
    end
  end
end
