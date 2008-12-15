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

      def format(io, indent)
        space = " " * indent
        indented = space + value.split("\n").map{|line| line.strip}.join("\n#{space}")
        io.write(indented)
        io.write("\n")
      end
    end
  end
end