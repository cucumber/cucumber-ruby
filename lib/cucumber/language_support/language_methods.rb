module Cucumber
  module LanguageSupport
    module LanguageMethods
      def before(scenario)
        step_mother.begin_scenario
        execute_before(scenario)
      end

      def after(scenario)
        execute_after(scenario)
        step_mother.end_scenario
      end

      def execute_before(scenario)
        step_mother.hooks_for(:before, scenario).each do |hook|
          invoke(hook, 'Before', scenario, true)
        end
      end

      def execute_after(scenario)
        step_mother.hooks_for(:after, scenario).each do |hook|
          invoke(hook, 'After', scenario, true)
        end
      end

      def execute_after_step(scenario)
        step_mother.hooks_for(:after_step, scenario).each do |hook|
          invoke(hook, 'AfterStep', scenario, false)
        end
      end

      private

      def invoke(hook, location, scenario, exception_fails_scenario)
        begin
          hook.invoke(location, scenario)
        rescue Exception => exception
          if exception_fails_scenario
            scenario.fail!(exception)
          else
            raise
          end
        end
      end
    end
  end
end