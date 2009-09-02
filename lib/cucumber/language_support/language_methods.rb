module Cucumber
  module LanguageSupport
    module LanguageMethods
      def before(scenario)
        begin_scenario
        execute_before(scenario)
      end

      def after(scenario)
        execute_after(scenario)
        end_scenario
      end
      
      def after_configuration(configuration)
        hooks[:after_configuration].each do |hook|
          hook.invoke('AfterConfiguration', configuration)
        end
      end

      def execute_after_step(scenario)
        hooks_for(:after_step, scenario).each do |hook|
          invoke(hook, 'AfterStep', scenario, false)
        end
      end

      def add_hook(phase, hook)
        hooks[phase.to_sym] << hook
        hook
      end

      def add_step_definition(step_definition)
        step_definitions << step_definition
        step_definition
      end

      def step_definitions
        @step_definitions ||= []
      end

      def hooks_for(phase, scenario) #:nodoc:
        hooks[phase.to_sym].select{|hook| scenario.accept_hook?(hook)}
      end

      private

      def hooks
        @hooks ||= Hash.new{|h,k| h[k] = []}
      end

      def execute_before(scenario)
        hooks_for(:before, scenario).each do |hook|
          invoke(hook, 'Before', scenario, true)
        end
      end

      def execute_after(scenario)
        hooks_for(:after, scenario).each do |hook|
          invoke(hook, 'After', scenario, true)
        end
      end

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