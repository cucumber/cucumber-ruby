module Cucumber
  module Ast
    # Represents the root node of a parsed feature.
    class Feature
      attr_accessor :file
      attr_writer :features
      attr_reader :name

      def initialize(background, comment, tags, name, feature_elements)
        @background, @comment, @tags, @name, @feature_elements = background, comment, tags, name, feature_elements

        background.feature = self if background
        @feature_elements.each do |feature_element|
          feature_element.feature = self
        end
      end

      def accept(visitor)
        visitor.visit_comment(@comment) unless @comment.empty?
        visitor.visit_tags(@tags)
        visitor.visit_feature_name(@name)
        visitor.visit_background(@background) if @background
        @feature_elements.each do |feature_element|
          visitor.visit_feature_element(feature_element)
        end
      end

      def accept_hook?(hook)
        @tags.accept_hook?(hook)
      end

      def next_feature_element(feature_element, &proc)
        index = @feature_elements.index(feature_element)
        next_one = @feature_elements[index+1]
        proc.call(next_one) if next_one
      end

      def backtrace_line(step_name, line)
        "#{file_colon_line(line)}:in `#{step_name}'"
      end

      def file_colon_line(line)
        "#{@file}:#{line}"
      end

      def to_sexp
        sexp = [:feature, @file, @name]
        comment = @comment.to_sexp
        sexp += [comment] if comment
        tags = @tags.to_sexp
        sexp += tags if tags.any?
        sexp += [@background.to_sexp] if @background
        sexp += @feature_elements.map{|fe| fe.to_sexp}
        sexp
      end
    end
  end
end
