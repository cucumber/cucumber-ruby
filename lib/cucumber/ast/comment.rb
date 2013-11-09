module Cucumber
  module Ast
    # Holds the value of a comment parsed from a feature file:
    #
    #   # Lorem ipsum
    #   # dolor sit amet
    #
    # This gets parsed into a Comment with value <tt>"# Lorem ipsum\n# dolor sit amet\n"</tt>
    #
    class Comment #:nodoc:
      def initialize(value)
        # for jRuby as Java::JavaUtil::ArrayList is not an Array
        if value.respond_to?(:map)
          @value = value.map(&:value).join("\n")
        else
          @value = value
        end
      end

      def accept(visitor)
        return if @value.empty?
        visitor.visit_comment(self) do
          @value.strip.split("\n").each do |line|
            visitor.visit_comment_line(line.strip)
          end
        end
      end

      def to_sexp
        @value.empty? ? nil : [:comment, @value]
      end
    end
  end
end
