module Cucumber
  module Ast
    class Scenario
      def initialize(comment, tags, line, keyword, name, steps)
        @comment, @tags, @line, @keyword, @name = comment, tags, line, keyword, name
        steps.each {|step| step.scenario = self}
        @steps = steps
      end

      def accept(visitor)
        visitor.visit_comment(@comment)
        visitor.visit_tags(@tags)
        visitor.visit_scenario_name(@keyword, @name)
        visitor.world(self) do |world|
          previous = :passed
          @steps.each do |step|
            previous = step.execute(world, previous, visitor)
            visitor.visit_step(step)
          end
        end
      end

      def max_step_length
        @steps.map{|step| step.text_length}.max
      end

      def at_eny_line?(lines)
        lines.each {|line| return true if at_line?(line)}
        false
      end

      def at_line?(line)
        if @line == line
          true
        else
          @steps.each {|step| return true if step.at_line?(line)}
          false
        end
      end

      def to_sexp
        sexp = [:scenario, @line, @keyword, @name]
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
