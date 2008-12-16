require 'cucumber/step_definition'

module Cucumber
  # This is the future StepMother
  module StepMom
    
    def execute_step_definition(step_name, world)
      step_definition = find_step_definition(step_name)
      begin
        step_definition.execute_in(world, step_name)
      rescue Exception => e
        method_line = "#{__FILE__}:#{__LINE__ - 2}:in `execute_step_definition'"
        step_definition.strip_backtrace!(e, method_line)
        raise e
      end
    end
    
    def format(step_name, format)
      step_definition = find_step_definition(step_name)
      step_definition.format(step_name, format)
    end
    
    def find_step_definition(step_name)
      found = @step_definitions.select do |step_definition|
        step_definition.match(step_name)
      end
      found[0]
    end
    
    def Given(regexp, &proc)
      @step_definitions ||= []
      @step_definitions << StepDefinition.new(regexp, &proc)
    end
  end
end