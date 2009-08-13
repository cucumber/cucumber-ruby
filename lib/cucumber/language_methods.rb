module Cucumber
  module LanguageMethods
    def before(step_mother, scenario)
      step_mother.new_world
      execute_before(step_mother, scenario)
    end
    
    def after(step_mother, scenario)
      execute_after(step_mother, scenario)
      step_mother.nil_world
    end

    def execute_before(step_mother, scenario)
      step_mother.hooks_for(:before, scenario).each do |hook|
        invoke(hook, 'Before', scenario, true)
      end
    end

    def execute_after(step_mother, scenario)
      step_mother.hooks_for(:after, scenario).each do |hook|
        invoke(hook, 'After', scenario, true)
      end
    end

    def execute_after_step(step_mother, scenario)
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