# frozen_string_literal: true

module Cucumber
  class Runtime
    class StepHooks
      def initialize(id_generator, hooks)
        @hooks = hooks
        @id_generator = id_generator
      end

      def apply(test_steps)
        test_steps.flat_map do |test_step|
          [test_step] + after_step_hooks(test_step)
        end
      end

      private

      def after_step_hooks(test_step)
        @hooks.map do |hook|
          action = ->(*args) { hook.invoke('AfterStep', [args, test_step]) }
          Hooks.after_step_hook(@id_generator.new_id, test_step, hook.location, &action)
        end
      end
    end
  end
end
