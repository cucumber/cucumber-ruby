module Cucumber
  class StepMatch
    def initialize(step_definition, step_name, args)
      @step_definition, @step_name, @args = step_definition, step_name, args
    end
    
    def invoke(world, multiline_arg)
      all_args = (@args + [multiline_arg])
      @step_definition.invoke(world, all_args)
    end

    def format_args(format)
      if @step_definition
        @step_definition.format_args(@step_name, format)
      else
        @step_name
      end
    end
    
    def file_colon_line
      @step_definition.file_colon_line
    end
  end
end