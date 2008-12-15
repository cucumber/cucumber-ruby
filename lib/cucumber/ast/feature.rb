module Cucumber
  module Ast
    # Represents the root node of a parsed feature.
    class Feature
      attr_accessor :file
      attr_reader :comment
      attr_reader :tags
      attr_reader :feature_elements

      def initialize(comment, tags, feature_elements)
        @comment = comment
        @tags = tags
        @feature_elements = feature_elements
      end

      def format(io)
        comment.format(io)
        tags.format(io)
      end
    end
  end
end
