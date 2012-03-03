module Cucumber
  module Ast
    # Represents an inline argument in a step. Example:
    #
    #   Given the message
    #     """
    #     I like
    #     Cucumber sandwich
    #     """
    #
    # The text between the pair of <tt>"""</tt> is stored inside a DocString,
    # which is yielded to the StepDefinition block as the last argument.
    #
    # The StepDefinition can then access the String via the #to_s method. In the
    # example above, that would return: <tt>"I like\nCucumber sandwich"</tt>
    #
    # Note how the indentation from the source is stripped away.
    #
    class DocString < String #:nodoc:
      attr_accessor :file

      def self.default_arg_name
        "string"
      end

      attr_reader :content_type

      def initialize(string, content_type)
        @content_type = content_type
        super string
      end

      def to_step_definition_arg
        self
      end

      def accept(visitor)
        return if Cucumber.wants_to_quit
        visitor.visit_doc_string(self)
      end
      
      def arguments_replaced(arguments) #:nodoc:
        string = self
        arguments.each do |name, value|
          value ||= ''
          string = string.gsub(name, value)
        end
        DocString.new(string, content_type)
      end

      def has_text?(text)
        index(text)
      end

      # For testing only
      def to_sexp #:nodoc:
        [:doc_string, to_step_definition_arg]
      end
    end
  end
end
