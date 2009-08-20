module Cucumber
  module RbSupport
    # All steps are run in the context of an object that extends this module.
    module RbWorld
      class << self
        def alias_adverb(adverb)
          alias_method adverb, :__cucumber_invoke
        end
      end
    
      attr_writer :__cucumber_step_mother

      # Call a step from within a step definition. This method is aliased to
      # the same i18n as RbDsl.
      def __cucumber_invoke(name, multiline_argument=nil) #:nodoc:
        begin
          step_match = @__cucumber_step_mother.step_match(name)
          step_match.invoke(multiline_argument)
        rescue Exception => e
          e.nested! if Undefined === e
          raise e
        end
      end

      # Returns a Cucumber::Ast::Table for +text_or_table+, which can either
      # be a String:
      #
      #   table(%{
      #     | account | description | amount |
      #     | INT-100 | Taxi        | 114    |
      #     | CUC-101 | Peeler      | 22     |
      #   })
      #
      # or a 2D Array:
      #
      #   table([
      #     %w{ account description amount },
      #     %w{ INT-100 Taxi        114    },
      #     %w{ CUC-101 Peeler      22     }
      #   ])
      #
      def table(text_or_table, file=nil, line_offset=0)
        if Array === text_or_table
          Ast::Table.new(text_or_table)
        else
          @table_parser ||= Parser::TableParser.new
          @table_parser.parse_or_fail(text_or_table.strip, file, line_offset)
        end
      end

      # Output +announcement+ alongside the formatted output.
      # This is an alternative to using Kernel#puts - it will display
      # nicer, and in all outputs (in case you use several formatters)
      #
      # Beware that the output will be printed *before* the corresponding
      # step. This is because the step itself will not be printed until
      # after it has run, so it can be coloured according to its status.
      def announce(announcement)
        @__cucumber_step_mother.announce(announcement)
      end

      # Mark the matched step as pending.
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

      # The default implementation of Object#inspect recursively
      # traverses all instance variables and invokes inspect. 
      # This can be time consuming if the object graph is large.
      #
      # This can cause unnecessary delays when certain exceptions 
      # occur. For example, MRI internally invokes #inspect on an 
      # object that raises a NoMethodError. (JRuby does not do this).
      #
      # A World object can have many references created by the user
      # or frameworks (Rails), so to avoid long waiting times on
      # such errors in World we define it to just return a simple String.
      #
      def inspect #:nodoc:
        sprintf("#<%s:0x%x>", self.class, self.object_id)
      end
    end
  end
end