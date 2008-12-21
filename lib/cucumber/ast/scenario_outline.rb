module Cucumber
  module Ast
    class ScenarioOutline
      def initialize(comment, tags, name, steps, matrix)
        @comment, @tags, @name, @steps = comment, tags, name, steps
        outline_table = OutlineTable.new(matrix, self)
        @hashes = outline_table.hashes
        @examples = Examples.new(self, outline_table)
      end

      def accept(visitor)
        @row_index = 0
        visitor.visit_comment(@comment)
        visitor.visit_tags(@tags)
        visitor.visit_scenario_name(@name)
        visitor.visit_examples(@examples)
      end

      def execute_row(hash)
        @world = Object.new
        @steps.each do |step|
          step.execute_with_arguments(hash)
        end
      end
    end
  end
end
