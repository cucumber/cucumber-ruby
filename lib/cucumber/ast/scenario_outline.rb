module Cucumber
  module Ast
    class ScenarioOutline
      include FeatureElement
      
      attr_writer :background
      attr_writer :feature

      # The +example_sections+ argument must be an Array where each element is another array representing
      # an Examples section. This array has 3 elements:
      #
      # * Examples keyword
      # * Examples section name
      # * Raw matrix
      def initialize(comment, tags, line, keyword, name, steps, example_sections)
        @comment, @tags, @line, @keyword, @name = comment, tags, line, keyword, name
        attach_steps(steps)
        @steps ||= StepCollection.new(steps)

        @examples_array = example_sections.map do |example_section|
          examples_line       = example_section[0]
          examples_keyword    = example_section[1]
          examples_name       = example_section[2]
          examples_matrix     = example_section[3]

          examples_table = OutlineTable.new(examples_matrix, self)
          Examples.new(examples_line, examples_keyword, examples_name, examples_table)
        end
      end

      def at_lines?(lines)
        super || @examples_array.detect { |examples| examples.at_lines?(lines) }
      end

      def accept(visitor)
        visitor.visit_comment(@comment)
        visitor.visit_tags(@tags)
        visitor.visit_scenario_name(@keyword, @name, file_line(@line), source_indent(text_length))
        visitor.visit_steps(@steps)

        @examples_array.each do |examples|
          visitor.visit_examples(examples)
        end
      end

      def each_example_row(&proc)
        @examples_array.each do |examples|
          examples.each_example_row(&proc)
        end
      end

      def step_invocations(cells)
        @steps.step_invocations_from_cells(cells)
      end

      def pending? ; false ; end

      def to_sexp
        sexp = [:scenario_outline, @keyword, @name]
        comment = @comment.to_sexp
        sexp += [comment] if comment
        tags = @tags.to_sexp
        sexp += tags if tags.any?
        steps = @steps.to_sexp
        sexp += steps if steps.any?
        sexp += @examples_array.map{|e| e.to_sexp}
        sexp
      end
    end
  end
end
