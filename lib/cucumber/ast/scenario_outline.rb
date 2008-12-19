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
      end

      def push_arg(cell_arg)
        @args ||= []
        @args << cell_arg

        if(replaced_name = @steps[0].outline_name(@args))
          @args = nil
          @steps[0].world = @world
          @steps[0].execute(replaced_name)
        end
      end
    end
  end
end
