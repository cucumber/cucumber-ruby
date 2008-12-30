module Cucumber
  module Ast
    class Scenario
      def initialize(step_mother, comment, tags, keyword, name, step_names_and_multiline_args)
        @step_mother, @comment, @tags, @keyword, @name = step_mother, comment, tags, keyword, name
        @steps = step_names_and_multiline_args.map{|saia| Step.new(self, nil, *saia)}
      end

      def accept(visitor)
        visitor.visit_comment(@comment)
        visitor.visit_tags(@tags)
        visitor.visit_scenario_name(@keyword, @name)
        @step_mother.world(self) do |world|
          previous = :passed
          @steps.each do |step|
            previous = step.execute(world, previous)
            visitor.visit_step(step)
          end
        end
      end

      def step_invocation(step_name, world)
        @step_mother.step_invocation(step_name, world)
      end

      def max_step_length
        @steps.map{|step| step.text_length}.max
      end

      def to_sexp
        sexp = [:scenario, @keyword, @name]
        comment = @comment.to_sexp
        sexp += [comment] if comment
        tags = @tags.to_sexp
        sexp += tags if tags.any?
        steps = @steps.map{|step| step.to_sexp}
        sexp += steps if steps.any?
        sexp
      end
    end
  end
end
