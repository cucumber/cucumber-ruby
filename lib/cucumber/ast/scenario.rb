module Cucumber
  module Ast
    class Scenario < Background
      attr_writer :background
      
      def initialize(comment, tags, line, keyword, name, steps)
        @comment, @tags, @line, @keyword, @name = comment, tags, line, keyword, name
        steps.each {|step| step.scenario = self}
        @steps = steps
        @steps_helper = Steps.new(self)
      end

       def status
        @steps.map{|step| step.status}
      end

      def tagged_with?(tag_names)
        @tags.among?(tag_names) || @background.tagged_with?(tag_names, false)
      end

      def matches_scenario_names?(scenario_names)
        scenario_names.detect{|name| @name == name}
      end

      def accept(visitor)
        visitor.visit_comment(@comment)
        visitor.visit_tags(@tags)
        visitor.visit_scenario_name(@keyword, @name, file_line(@line), source_indent(text_length))
        visitor.visit_steps(@steps_helper)

        @feature.scenario_executed(self) if @feature && !@executed
        @executed = true
      end

      def accept_steps(visitor)
        previous = @background.status
        @steps.each do |step|
          step.previous = previous
          step.world    = @background.world
          visitor.visit_step(step)
          previous = step.status
        end
      end

      def at_lines?(lines)
        at_header_or_step_lines?(lines)
      end

      def at_header_or_step_lines?(lines)
        lines.empty? || lines.index(@line) || @steps.detect {|step| step.at_lines?(lines)} || @tags.at_lines?(lines)
      end

      def step_executed(step)
        @feature.step_executed(step) if @feature
      end

      def text_length
        super + @name.jlength
      end

      def previous_step(step)
        i = @steps.index(step) || -1
        @steps[i-1]
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
