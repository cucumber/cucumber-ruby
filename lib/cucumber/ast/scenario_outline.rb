module Cucumber
  module Ast
    class ScenarioOutline < Scenario
      # The +example_sections+ argument must be an Array where each element is another array representing
      # an Examples section. This array has 3 elements:
      #
      # * Examples keyword
      # * Examples section name
      # * Raw matrix
      def initialize(comment, tags, keyword, name, step_names_and_multiline_args, example_sections)
        @comment, @tags, @keyword, @name = comment, tags, keyword, name
        @steps = step_names_and_multiline_args.map{|saia| Step.new(self, :outline, *saia)}

        @examples_array = example_sections.map do |example_section|
          examples_keyword    = example_section[0]
          examples_name       = example_section[1]
          examples_matrix     = example_section[2]

          examples_table = OutlineTable.new(examples_matrix, self)
          Examples.new(examples_keyword, examples_name, examples_table)
        end
      end

      def accept(visitor)
        visitor.visit_comment(@comment)
        visitor.visit_tags(@tags)
        visitor.visit_scenario_name(@keyword, @name)
        @steps.each do |step|
          visitor.visit_step(step)
        end
        @examples_array.each do |examples|
          visitor.visit_examples(examples)
        end
      end

      def execute_row(hash, visitor)
        visitor.world(self) do |world|
          previous = :passed
          @steps.each do |step|
            previous = step.execute_with_arguments(hash, world, previous, visitor)
          end
        end
      end

      def to_sexp
        sexp = [:scenario_outline, @keyword, @name]
        comment = @comment.to_sexp
        sexp += [comment] if comment
        tags = @tags.to_sexp
        sexp += tags if tags.any?
        steps = @steps.map{|step| step.to_sexp}
        sexp += steps if steps.any?
        sexp += @examples_array.map{|e| e.to_sexp}
        sexp
      end
    end
  end
end
