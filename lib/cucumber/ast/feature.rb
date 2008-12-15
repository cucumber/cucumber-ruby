module Cucumber
  module Ast
    # Represents the root node of a parsed feature.
    class Feature
      attr_accessor :file
      attr_reader :comment, :tags, :name, :feature_elements

      def initialize(comment, tags, name, feature_elements)
        @comment, @tags, @name, @feature_elements = comment, tags, name, feature_elements
      end

      def format(io)
        comment.format(io, 0)
        tags.format(io)
        io.write("Feature: #{@name}\n\n")
        feature_elements.each {|feature_element| feature_element.format(io)}
      end
    end
  end
end
