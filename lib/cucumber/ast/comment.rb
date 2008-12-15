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

      def format(io)
        io.write(@value)
      end
    end
  end
end