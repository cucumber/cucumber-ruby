module Cucumber
  module Ast
    class Scenario
      attr_writer :feature
      
      def initialize(comment, tags, line, keyword, name, steps)
        @comment, @tags, @line, @keyword, @name = comment, tags, line, keyword, name
        steps.each {|step| step.scenario = self}
        @steps = steps
      end

      def accept(visitor)
        visitor.visit_comment(@comment)
        visitor.visit_tags(@tags)
        visitor.visit_scenario_name(@keyword, @name, file_line(@line), comment_padding(text_length))
        visitor.world(self) do |world|
          previous = :passed
          @steps.each do |step|
            step.previous = previous
            step.world    = world
            visitor.visit_step(step)
            previous = step.status
          end
        end
      end

      def comment_padding(text_length)
        max_line_length - text_length
      end

      def max_line_length
        lengths = (@steps + [self]).map{|e| e.text_length}
        lengths.max
      end

      def text_length
        @keyword.jlength + @name.jlength
      end

      def at_any_line?(lines)
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

      def pending?
        @steps.empty?
      end
      
      def step_executed(step)
        @feature.step_executed(step) if @feature
      end

      def backtrace_line(step_name, line)
        @feature.backtrace_line(step_name, line) if @feature
      end

      def file_line(line)
        @feature.file_line(line) if @feature
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
