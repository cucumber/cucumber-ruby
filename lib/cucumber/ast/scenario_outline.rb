module Cucumber
  module Ast
    class ScenarioOutline
      def initialize(comment, tags, name, steps, matrix)
        @comment, @tags, @name, @steps, @examples = comment, tags, name, steps, Examples.new(self, matrix)
      end

      def accept(visitor)
        visitor.visit_comment(@comment)
        visitor.visit_tags(@tags)
        visitor.visit_scenario_name(@name)
        visitor.visit_examples(@examples)
      end

      def prepare
        @world = Object.new
        @dupe_steps = @steps.dup
        next_step
      end

      def push_arg(cell_arg)
        @args << cell_arg

        if(replaced_name = @current_step.outline_name(*@args))
          step = @current_step
          next_step
          step.execute(replaced_name)
        end
      end

      private

      def next_step
        return if @dupe_steps.empty?
        @current_step = @dupe_steps.shift
        @current_step.world = @world
        @args = []
      end
    end
  end
end
