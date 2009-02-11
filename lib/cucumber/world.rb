module Cucumber
  # All steps are run in the context of an object that extends this module
  module World
    class << self
      def alias_adverb(adverb)
        alias_method adverb, :__cucumber_invoke
      end
    end
    
    attr_writer :__cucumber_step_mother, :__cucumber_current_step

    # Call a step from within a step definition
    def __cucumber_invoke(name, *multiline_arguments) #:nodoc:
      begin
        # TODO: Very similar to code in Step. Refactor. Get back StepInvocation?
        # Make more similar to JBehave?
        step_definition = @__cucumber_step_mother.step_definition(name)
        matched_args = step_definition.matched_args(name)
        args = (matched_args + multiline_arguments)
        step_definition.execute(name, self, *args)
      rescue Exception => e
        @__cucumber_current_step.exception = e
        raise e
      end
    end
    
    def table(text, file=nil, line=0)
      @table_parser ||= Parser::TableParser.new
      @table_parser.parse_or_fail(text.strip, file, line)
    end

    def pending(message = "TODO")
      if block_given?
        begin
          yield
        rescue Exception => e
          raise Pending.new(message)
        end
        raise Pending.new("Expected pending '#{message}' to fail. No Error was raised. No longer pending?")
      else
        raise Pending.new(message)
      end
    end
  end
end