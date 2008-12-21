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
        super
        visitor.visit_examples(@examples)
      end

      def execute_row(hash)
        world = @step_mother.new_world
        @steps.each do |step|
          step.execute_with_arguments(hash, world)
        end
      end

      def new_world_for_steps
      end
    end
  end
end
