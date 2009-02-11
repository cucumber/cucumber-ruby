module Cucumber
  class StepInvocation
    attr_reader :status, :exception
    
    def initialize(step_mother, options, step, previous, world)
      @step_mother, @options, @step, @previous, @world = step_mother, options, step, previous, world
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
        
      visitor.visit_step_name(@step.keyword, @step.name, @status, @step_match, 10)
      # TODO: Keep our own copy of multiline_args - with any arguments replaced
      @step.multiline_args.each do |multiline_arg|
        visitor.visit_multiline_arg(multiline_arg, @status)
      end
      @exception # TODO: Don't return anything - pass exception to visit call
    end

    def invoke
      return if @status
      begin
        @status = :skipped
        step_match = @step_mother.step_match(@step.name)
        if @previous == :passed && !options[:dry_run]
          @step.invoke(step_match, @world)
          @status = :passed
        end
      rescue Undefined => exception
        if options[:strict]
          exception.set_backtrace([])
          failed(exception)
        else
          @status = :undefined
        end
      rescue Pending => exception
        @status = :pending
      rescue Exception => exception
        failed(exception)
      end
      nil
    end

    def failed(exception)
      @status = :failed
      @exception = exception
      @exception.backtrace << @step.backtrace_line unless @step.backtrace_line.nil?
    end

    private

    def options
      @options || {}
    end
  end
end