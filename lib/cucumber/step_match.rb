module Cucumber
  class StepMatch
    def initialize(step_definition, args)
      @step_definition, @args = step_definition, args
    end
    
    def invoke(world, multiline_args)
      all_args = (@args + multiline_args)
      @step_definition.invoke(world, all_args)
    end
  end
end