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
    # The text between the pair of <tt>"""</tt> is stored inside a PyString,
    # which is yielded to the StepDefinition block as the last argument.
    #
    # The StepDefinition can then access the String via the #to_s method. In the
    # example above, that would return: <tt>"I like\nCucumber sandwich"</tt>
    #
    # Note how the indentation from the source is stripped away.
    #
    class PyString
      def initialize(start_line, end_line, string, quotes_indent)
        @start_line, @end_line = start_line, end_line
        @string, @quotes_indent = string.gsub(/\\"/, '"'), quotes_indent
        @status = :passed
      end

      def status=(status)
        @status = status
      end

      def to_s
        @string.indent(-@quotes_indent)
      end

      def matches_lines?(lines)
        lines.detect{|l| l >= @start_line && l <= @end_line}
      end

      def accept(visitor)
        visitor.visit_py_string(to_s, @status)
      end
      
      def arguments_replaced(arguments) #:nodoc:
        string = @string
        arguments.each do |name, value|
          value ||= ''
          string = string.gsub(name, value)
        end
        PyString.new(@start_line, @end_line, string, @quotes_indent)
      end
      
      # For testing only
      def to_sexp #:nodoc:
        [:py_string, to_s]
      end
    
    end
  end
end
