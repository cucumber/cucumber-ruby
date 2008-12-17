require 'cucumber/step_definition'

module Cucumber
  # This is the future StepMother
  module StepMom

    class Pending < StandardError
    end

    class Multiple < StandardError
    end

    class Duplicate < StandardError
      def initialize(step_def_1, step_def_2)
      end
    end
    
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
      found = step_definitions.select do |step_definition|
        step_definition.match(step_name)
      end
      raise Pending.new(step_name) if found.empty?
      raise Multiple.new(step_name) if found.size > 1
      found[0]
    end
    
    def Given(regexp, &proc)
      register_step_definition(regexp, &proc)
    end
    
  private

    def register_step_definition(regexp, &proc)
      step_definition = StepDefinition.new(regexp, &proc)
      step_definitions.each do |already|
        raise Duplicate.new(already, step_definition) if already.match(regexp)
      end
      step_definitions << step_definition
    end

    def step_definitions
      @step_definitions ||= []
    end
  end
end