module Cucumber
  module Ast
    class ScenarioOutline < Scenario
      def initialize(step_mother, comment, tags, name, step_names, matrix)
        @step_mother, @comment, @tags, @name = step_mother, comment, tags, name
        @steps = step_names.map{|names| Step.new(step_mother, true, *names)}
        outline_table = OutlineTable.new(matrix, self)
        @examples = Examples.new(self, outline_table)
      end

      def accept(visitor)
        visitor.visit_comment(@comment)
        visitor.visit_tags(@tags)
        visitor.visit_scenario_name(@name)
        @steps.each do |step|
          visitor.visit_step(step)
        end
        visitor.visit_examples(@examples)
      end

      def execute_row(hash)
        @step_mother.new_world!
        @steps.each do |step|
          step.execute_with_arguments(hash)
        end
      end
    end
  end
end
