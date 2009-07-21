module Cucumber
  module Ast
    # A dumb visitor that implements the whole Visitor API and just walks the tree.
    class Visitor
      attr_accessor :options
      attr_reader :step_mother

      def initialize(step_mother)
        @options = {}
        @step_mother = step_mother
      end

      def matches_scenario_names?(node)
        scenario_name_regexps = options[:name_regexps] || []
        scenario_name_regexps.empty? || node.matches_scenario_names?(scenario_name_regexps)
      end

      def visit_features(features)
        features.accept(self)
      end

      def visit_feature(feature)
        feature.accept(self)
      end

      def visit_comment(comment)
        comment.accept(self)
      end

      def visit_comment_line(comment_line)
      end

      def visit_tags(tags)
        tags.accept(self)
      end

      def visit_tag_name(tag_name)
      end

      def visit_feature_name(name)
      end

      # +feature_element+ is either Scenario or ScenarioOutline
      def visit_feature_element(feature_element)
        feature_element.accept(self)
      end

      def visit_background(background)
        background.accept(self)
      end

      def visit_background_name(keyword, name, file_colon_line, source_indent)
      end

      def visit_examples_array(examples_array)
        examples_array.accept(self)
      end

      def visit_examples(examples)
        examples.accept(self)
      end

      def visit_examples_name(keyword, name)
      end

      def visit_outline_table(outline_table)
        @table = outline_table
        outline_table.accept(self)
      end

      def visit_scenario_name(keyword, name, file_colon_line, source_indent)
      end

      def visit_steps(steps)
        steps.accept(self)
      end

      def visit_step(step)
        step.accept(self)
      end

      def visit_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        visit_step_name(keyword, step_match, status, source_indent, background)
        visit_multiline_arg(multiline_arg) if multiline_arg
        visit_exception(exception, status) if exception
      end

      def visit_step_name(keyword, step_match, status, source_indent, background) #:nodoc:
      end

      def visit_multiline_arg(multiline_arg) #:nodoc:
        multiline_arg.accept(self)
      end

      def visit_exception(exception, status) #:nodoc:
      end

      def visit_py_string(string)
      end

      def visit_table_row(table_row)
        table_row.accept(self)
      end

      def visit_table_cell(table_cell)
        table_cell.accept(self)
      end

      def visit_table_cell_value(value, status)
      end

      def announce(announcement)
      end

    end
  end
end
