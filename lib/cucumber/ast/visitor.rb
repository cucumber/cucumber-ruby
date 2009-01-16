module Cucumber
  module Ast
    # A dumb visitor that implements the whole Visitor API and just walks the tree.
    class Visitor
      def initialize(step_mother)
        @step_mother = step_mother
      end

      def world(scenario, &proc)
        @step_mother.world(scenario, &proc)
      end

      def step_invocation(step_name, world)
        @step_mother.step_invocation(step_name, world)
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

      def visit_examples(examples)
        examples.accept(self)
      end

      def visit_examples_name(keyword, name)
      end

      def visit_scenario_name(keyword, name, file_line, comment_padding)
      end

      def visit_step(step)
        step.accept(self)
      end

      def visit_step_name(gwt, step_name, status, step_invocation, comment_padding)
      end

      def visit_multiline_arg(multiline_arg, status)
        multiline_arg.accept(self, status)
      end

      def visit_py_string(string, status)
      end

      def visit_table_row(table_row, status)
        table_row.accept(self, status)
      end

      def visit_table_cell(table_cell, status)
        table_cell.accept(self, status)
      end

      def visit_table_cell_value(value, width, status)
      end

      def visit_step_exception(error)
      end
    end
  end
end
