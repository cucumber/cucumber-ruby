module Cucumber
  class Runtime
    class AfterHooks
      def initialize(action_blocks)
        @action_blocks = action_blocks
      end

      def apply_to(test_case)
        test_case.with_steps(
          test_case.test_steps + after_hooks(test_case.source)
        )
      end

      private

      def after_hooks(source)
        @action_blocks.map do |action_block|
          Hooks.after_hook(source, &action_block)
        end
      end
    end
  end
end

