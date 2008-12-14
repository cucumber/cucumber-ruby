module Cucumber
  module Ast
    # Represents the root node of a parsed feature.
    class Feature
      attr_reader :comment
      
      def initialize(comment)
        @comment = comment
      end
    end
  end
end