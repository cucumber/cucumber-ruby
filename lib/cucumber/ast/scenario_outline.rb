module Cucumber
  module Ast
    class ScenarioOutline < Scenario
      # The +example_sections+ argument must be an Array where each element is another array representing
      # an Examples section. This array has 2 elements, the first one is the name of the Examples section,
      # the second one is a raw matrix
      def initialize(step_mother, comment, tags, name, step_names_and_multiline_args, example_sections)
        @step_mother, @comment, @tags, @name = step_mother, comment, tags, name
        @steps = step_names_and_multiline_args.map{|saia| Step.new(self, :outline, *saia)}

        @examples_array = example_sections.map do |example_section|
          examples_name       = example_section[0]
          examples_matrix     = example_section[1]

          examples_table = OutlineTable.new(examples_matrix, self)
          Examples.new(examples_name, examples_table)
        end
      end

      def accept(visitor)
        visitor.visit_comment(@comment)
        visitor.visit_tags(@tags)
        visitor.visit_scenario_name(@name)
        @steps.each do |step|
          visitor.visit_step(step)
        end
        @examples_array.each do |examples|
          visitor.visit_examples(examples)
        end
      end

      def execute_row(hash)
        @step_mother.world do |world|
          previous = :passed
          @steps.each do |step|
            previous = step.execute_with_arguments(hash, world, previous)
          end
        end
      end
    end
  end
end
