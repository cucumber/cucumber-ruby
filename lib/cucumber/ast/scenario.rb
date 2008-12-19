module Cucumber
  module Ast
    class Scenario
      def initialize(comment, tags, name, steps)
        @comment, @tags, @name, @steps = comment, tags, name, steps
      end

      def accept(visitor)
        visitor.visit_comment(@comment)
        visitor.visit_tags(@tags)
        visitor.visit_scenario_name(@name)
        @steps.each do |step|
          # TODO - set the world here?
          visitor.visit_step(step)
        end
      end
    end
  end
end
