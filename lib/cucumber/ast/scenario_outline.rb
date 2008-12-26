module Cucumber
  module Ast
    class ScenarioOutline < Scenario
      def initialize(step_mother, comment, tags, name, step_names_and_multiline_args, example_matrix)
        @step_mother, @comment, @tags, @name = step_mother, comment, tags, name
        @steps = step_names_and_multiline_args.map{|saia| Step.new(self, true, *saia)}

        outline_table = OutlineTable.new(example_matrix, self)
        @examples = Examples.new(self, outline_table)
      end

      def accept(visitor)
        visitor.visit_comment(@comment)
        visitor.visit_tags(@tags)
        visitor.visit_scenario_name(@name)
        @steps.each do |step|
          visitor.visit_step(step, nil)
        end
        visitor.visit_examples(@examples)
      end

      def execute_row(hash)
        @step_mother.world do |world|
          @steps.each do |step|
            step.execute_with_arguments(hash, world)
          end
        end
      end
    end
  end
end
