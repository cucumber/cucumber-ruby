module Cucumber
  module StepMethods
    def Before(&proc)
      $story_runner.register_before_proc(&proc)
    end
    
    def After(&proc)
      $story_runner.register_after_proc(&proc)
    end

    def Given(key, &proc)
      $story_runner.register_proc(key, &proc)
    end

    def When(key, &proc)
      $story_runner.register_proc(key, &proc)
    end

    def Then(key, &proc)
      $story_runner.register_proc(key, &proc)
    end
  end
end
