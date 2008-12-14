module Cucumber
  module Ast
    # Represents the root node of a parsed feature.
    class Feature
      attr_accessor :file
      attr_reader :comment
      attr_reader :feature_elements
      
      def initialize(comment, feature_elements)
        @comment = comment
        @feature_elements = feature_elements
      end
    end
  end
end