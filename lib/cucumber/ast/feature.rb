module Cucumber
  module Ast
    # Represents the root node of a parsed feature.
    class Feature
      attr_accessor :file
      attr_writer :features, :lines

      def initialize(comment, tags, name, feature_elements)
        @comment, @tags, @name, @feature_elements = comment, tags, name, feature_elements
        @lines = []

        @feature_elements.each do |feature_element|
          feature_element.feature = self
        end
      end

      def accept(visitor)
        visitor.current_feature_lines = @lines
        visitor.visit_comment(@comment)
        visitor.visit_tags(@tags)
        visitor.visit_feature_name(@name)
        @feature_elements.each do |feature_element|
          feature_element.visit(visitor) if visitor.visit?(self) || visitor.visit?(feature_element)
        end
      end

      def visit?(visitor)
        visitor.visit?(self) ||
          @feature_elements.detect{ |feature_element| visitor.visit?(feature_element) }
      end

      def matches_tags?(tag_names)
        @tags.among?(tag_names)
      end

      def matches_scenario_names?(scenario_names)
        false
      end

      def matches_lines?(lines)
        false
      end

      def backtrace_line(step_name, line)
        "#{file_colon_line(line)}:in `#{step_name}'"
      end

      def file_colon_line(line)
        "#{@file}:#{line}"
      end

      def to_sexp
        sexp = [:feature, @name]
        comment = @comment.to_sexp
        sexp += [comment] if comment
        tags = @tags.to_sexp
        sexp += tags if tags.any?
        sexp += @background.to_sexp if @background
        sexp
      end
    end
  end
end
