module Cucumber
  module Ast
    class Scenario
      def initialize(step_mother, comment, tags, name, step_names_and_inline_args)
        @step_mother, @comment, @tags, @name = step_mother, comment, tags, name
        @steps = step_names_and_inline_args.map{|saia| Step.new(step_mother, false, *saia)}
      end

      def accept(visitor)
        visitor.visit_comment(@comment)
        visitor.visit_tags(@tags)
        visitor.visit_scenario_name(@name)
        world = new_world_for_steps
        @steps.each do |step|
          # TODO - set the world here?
          visitor.visit_step(step, world)
        end
      end

      def new_world_for_steps
        @step_mother.new_world
      end
    end
  end
end
