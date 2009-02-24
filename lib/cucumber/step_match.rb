module Cucumber
  class StepMatch
    def initialize(step_definition, step_name, formatted_step_name, args)
      @step_definition, @step_name, @formatted_step_name, @args = step_definition, step_name, formatted_step_name, args
    end
    
    def invoke(world, multiline_arg)
      all_args = @args.dup
      all_args << multiline_arg if multiline_arg
      @step_definition.invoke(world, all_args)
    end

    def format_args(format)
      @formatted_step_name || @step_definition.format_args(@step_name, format)
    end
    
    def file_colon_line
      @step_definition.file_colon_line
    end
  end
  
  class NoStepMatch
    def initialize(step)
      @step = step
    end
    
    def format_args(format)
      @step.name
    end

    def file_colon_line
      raise "FFF" unless @step.file_colon_line
      @step.file_colon_line
    end
  end
end