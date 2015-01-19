module Cucumber
  class Runtime
    class StepHooks
      def initialize(after)
        @after = after
      end

      def apply(test_steps)
        test_steps.flat_map do |test_step|
          [test_step] + after_step_hooks(test_step)
        end
      end

      private
      def after_step_hooks(test_step)
        @after.map do |action_block|
          Hooks.after_step_hook(test_step.source, &action_block)
        end
      end
    end
  end
end
