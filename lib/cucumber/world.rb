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
    def __cucumber_invoke(name, multiline_argument=nil) #:nodoc:
      begin
        step_match = @__cucumber_step_mother.step_match(name)
        step_match.invoke(self, multiline_argument)
      rescue Exception => e
        e.nested! if Undefined === e
        @__cucumber_current_step.exception = e
        raise e
      end
    end
    
    def table(text, file=nil, line_offset=0)
      @table_parser ||= Parser::TableParser.new
      @table_parser.parse_or_fail(text.strip, file, line_offset)
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