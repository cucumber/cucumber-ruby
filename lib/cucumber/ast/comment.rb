module Cucumber
  module Ast
    # Holds the value of a comment parsed from a feature file:
    #
    #   # Lorem ipsum
    #   # dolor sit amet
    #
    # This gets parsed into a Comment with value <tt>"# Lorem ipsum\n# dolor sit amet\n"</tt>
    #
    class Comment
      attr_reader :value
      
      def initialize(value)
        @value = value
      end

      # Returns the value of this comment - aligned and indented by +indent+ spaces
      def indented(indent)
        space = " " * indent
        space + value.split("\n").map{|line| line.strip}.join("\n#{space}") + "\n"
      end
    end
  end
end