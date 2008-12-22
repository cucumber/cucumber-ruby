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
        @step_mother.new_world!
        @steps.each do |step|
          visitor.visit_step(step)
        end
      end
    end
  end
end
