module Cucumber
  class StepInvocation
    attr_writer :step_collection
    attr_reader :status, :exception
    
    def initialize(step_mother, options, step, world)
      @step_mother, @options, @step, @world = step_mother, options, step, world
    end
    
    # TODO: name, actual_keyword and padding in accept should be members
    
    def name
      @step.name
    end

    def actual_keyword
      @step.actual_keyword
    end
    
    def accept(visitor)
      unless @status
        invoke
        visitor.step_executed(self)
      end
      @step.visit_step_name(visitor, @step_match, @exception)
    end

    def invoke
      return if @invoked
      begin
        @step_match = @step_mother.step_match(@step.name)
        unless previous.exception || options[:dry_run]
          begin
            @step.invoke(@step_match, @world)
          rescue Pending => exception
            @exception = exception
          rescue Exception => exception
            @exception = exception
            append_backtrace
          end
        end
      rescue Undefined => exception
        @step_match = StepMatch.new(nil, @step.name, [])
        @exception = exception
        @exception.set_backtrace([])
        append_backtrace
      end
      @invoked = true
    end

    def append_backtrace
      @exception.backtrace << @step.backtrace_line unless @step.backtrace_line.nil?
    end

    def previous
      @step_collection.previous_step(self)
    end

    private

    def options
      @options || {}
    end
  end
end