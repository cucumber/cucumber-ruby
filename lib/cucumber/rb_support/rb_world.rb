require 'gherkin/formatter/ansi_escapes'

module Cucumber
  module RbSupport
    # Defines the basic DSL methods availlable in all Cucumber step definitions.
    #
    # You can, and probably should, extend this DSL with your own methods that
    # make sense in your domain. For more on that, see {Cucumber::RbSupport::RbDsl#World}
    module RbWorld

      # @private
      AnsiEscapes = Gherkin::Formatter::AnsiEscapes

      # Call a Transform with a string from another Transform definition
      def Transform(arg)
        rb = @__cucumber_runtime.load_programming_language('rb')
        rb.execute_transforms([arg]).first
      end

      # @private
      attr_writer :__cucumber_runtime, :__natural_language

      # Run a single Gherkin step
      # @example Call another step
      #   step "I am logged in"
      # @example Call a step with quotes in the name
      #   step %{the user "Dave" is logged in}
      # @example Passing a table
      #   step "the following users exist:", table(%{
      #     | name  | email           |
      #     | Matt  | matt@matt.com   |
      #     | Aslak | aslak@aslak.com |
      #   })
      # @example Passing a multiline string
      #   step "the email should contain:", "Dear sir,\nYou've won a prize!\n"
      # @param [String] name The name of the step
      # @param [String,Cucumber::Ast::DocString,Cucumber::Ast::Table] multiline_argument
      def step(name, multiline_argument=nil)
        @__cucumber_runtime.invoke(name, multiline_argument)
      end

      # Run a snippet of Gherkin
      # @example
      #   steps %{
      #     Given the user "Susan" exists
      #     And I am logged in as "Susan"
      #   }
      # @param [String] steps_text The Gherkin snippet to run
      def steps(steps_text)
        @__cucumber_runtime.invoke_steps(steps_text, @__natural_language, caller[0])
      end

      # Parse Gherkin into a {Cucumber::Ast::Table} object.
      #
      # Useful in conjunction with the #step method.
      # @example Create a table
      #   users = table(%{
      #     | name  | email           |
      #     | Matt  | matt@matt.com   |
      #     | Aslak | aslak@aslak.com |
      #   })
      # @param [String] text_or_table The Gherkin string that represents the table
      def table(text_or_table, file=nil, line_offset=0)
        @__cucumber_runtime.table(text_or_table, file, line_offset)
      end

      # Create an {Cucumber::Ast::DocString} object
      #
      # Useful in conjunction with the #step method, when
      # want to specify a content type.
      # @example Create a multiline string
      #   code = multiline_string(%{
      #     puts "this is ruby code"
      #   %}, 'ruby')
      def doc_string(string_without_triple_quotes, content_type='', line_offset=0)
        # TODO: rename this method to multiline_string
        @__cucumber_runtime.doc_string(string_without_triple_quotes, content_type, line_offset)
      end

      # @deprecated Use {#puts} instead.
      def announce(*messages)
        STDERR.puts AnsiEscapes.failed + "WARNING: #announce is deprecated. Use #puts instead:" + caller[0] + AnsiEscapes.reset
        puts(*messages)
      end

      # Print a message to the output.
      #
      # @note Cucumber might surprise you with the behaviour of this method. Instead
      #   of sending the output directly to STDOUT, Cucumber will intercept and cache
      #   the message until the current step has finished, and then display it.
      #
      #   If you'd prefer to see the message immediately, call {Kernel.puts} instead.
      def puts(*messages)
        @__cucumber_runtime.puts(*messages)
      end

      # Pause the tests and ask the operator for input
      def ask(question, timeout_seconds=60)
        @__cucumber_runtime.ask(question, timeout_seconds)
      end

      # Embed an image in the output
      def embed(file, mime_type, label='Screenshot')
        @__cucumber_runtime.embed(file, mime_type, label)
      end

      # Mark the matched step as pending.
      def pending(message = "TODO")
        if block_given?
          begin
            yield
          rescue Exception
            raise Pending.new(message)
          end
          raise Pending.new("Expected pending '#{message}' to fail. No Error was raised. No longer pending?")
        else
          raise Pending.new(message)
        end
      end

      # Mark the matched step as postponed.
      def postponed(message = "TODO")
        if block_given?
          begin
            yield
          rescue Exception
            raise Postponed.new(message)
          end
          raise Postponed.new("Expected postponed '#{message}' to fail. No Error was raised. No longer postponed?")
        else
          raise Postponed.new(message)
        end
      end

      # Prints the list of modules that are included in the World
      def inspect
        modules = [self.class]
        (class << self; self; end).instance_eval do
          modules += included_modules
        end
        sprintf("#<%s:0x%x>", modules.join('+'), self.object_id)
      end

      # see {#inspect}
      def to_s
        inspect
      end
    end
  end
end
