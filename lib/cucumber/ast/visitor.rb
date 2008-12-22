require 'cucumber/formatters/ansicolor'

module Cucumber
  module Ast
    # A dumb visitor that implements the whole Visitor API and just walks the tree.
    class Visitor
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

      def visit_examples(examples)
        examples.accept(self)
      end

      def visit_scenario_name(name)
      end

      def visit_step(step)
        step.accept(self)
      end

      def visit_step_name(gwt, step_name, status, invocation, comment_padding)
      end

      def visit_inline_arg(inline_arg, status)
        inline_arg.accept(self, status)
      end

      def visit_table_row(table_row, status)
        table_row.accept(self, status)
      end

      def visit_table_cell(table_cell, status)
        table_cell.accept(self, status)
      end

      def visit_table_cell_value(value, width, status)
      end

      def visit_step_error(error)
      end
    end
  end
end
