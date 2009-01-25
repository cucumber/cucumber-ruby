module Treetop
  module Runtime
    class SyntaxNode
      def line
        input.line_of(interval.first)
      end
    end
  end
end