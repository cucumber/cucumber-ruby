module Cucumber
  module Ast
    # Represents the root node of a parsed feature.
    class Feature
      attr_accessor :file
      attr_writer :features, :lines

      def initialize(comment, tags, name, feature_elements, background = nil)
        @comment, @tags, @name, @feature_elements, @background = comment, tags, name, feature_elements, background
        feature_elements.each do |feature_element| 
          feature_element.feature = self
          feature_element.background = background if background
        end
        background.feature = self if background
        @lines = []
      end

      def tagged_with?(tag_names, check_elements=true)
        @tags.among?(tag_names) || 
        (check_elements && @feature_elements.detect{|e| e.tagged_with?(tag_names)})
      end
      
      def matches_scenario_names?(scenario_names)
        @feature_elements.detect{|e| e.matches_scenario_names?(scenario_names)}
      end

      def accept(visitor)
        visitor.current_feature_lines = @lines
        visitor.visit_comment(@comment)
        visitor.visit_tags(@tags)
        visitor.visit_feature_name(@name)
        
        @feature_elements.each do |feature_element|
          visitor.visit_feature_element(feature_element) if @features.visit?(feature_element, @lines)
        end
      end

      def scenario_executed(scenario)
        @features.scenario_executed(scenario) if @features
      end

      def step_executed(step)
        @features.step_executed(step) if @features
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
        sexp += [@background.to_sexp] if @background
        sexp += @feature_elements.map{|e| e.to_sexp}
        sexp
      end
    end
  end
end
