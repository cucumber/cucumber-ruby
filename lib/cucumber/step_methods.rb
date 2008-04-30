module Cucumber
  module StepMethods
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
