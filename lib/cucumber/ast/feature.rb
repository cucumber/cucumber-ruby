module Cucumber
  module Ast
    # Represents the root node of a parsed feature.
    class Feature
      attr_accessor :file
      attr_writer :features, :lines

      def initialize(comment, tags, name, feature_elements, background = nil)
        @comment, @tags, @name, @background = comment, tags, name, background
        @background ||= Background.new
        @background.feature_elements = feature_elements
        @background.feature = self

        feature_elements.each do |feature_element| 
          feature_element.feature = self
          feature_element.background = @background
        end
        @lines = []
      end

      def tagged_with?(tag_names, check_background = true)
        @tags.among?(tag_names) || 
        (check_background && @background.tagged_with?(tag_names))
      end

      def visit?(feature_element)
        @features.visit?(feature_element, @lines)
      end
      
      def matches_scenario_names?(scenario_names)
        @background.matches_scenario_names?(scenario_names)
      end

      def accept(visitor)
        visitor.current_feature_lines = @lines
        visitor.visit_comment(@comment)
        visitor.visit_tags(@tags)
        visitor.visit_feature_name(@name)
        visitor.visit_background(@background)
      end

      def backtrace_line(step_name, line)
        "#{file_line(line)}:in `#{step_name}'"
      end

      def file_line(line)
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
