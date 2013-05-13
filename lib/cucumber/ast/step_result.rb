module Cucumber
  module Ast
    class StepResult
      attr_reader :keyword, :step_match, :exception, :status, :background,
                  :step_multiline_class, :file_colon_line

      def initialize(keyword, step_match, multiline_arg, status, exception, source_indent, background, file_colon_line)
        @keyword, @step_match, @multiline_arg, @status, @exception, @source_indent, @background, @file_colon_line = keyword, step_match, multiline_arg, status, exception, source_indent, background, file_colon_line
      end

      def accept(visitor)
        visitor.visit_step_name(@keyword, @step_match, @status, @source_indent, @background, @file_colon_line)
        visitor.visit_multiline_arg(@multiline_arg) if @multiline_arg
        visitor.visit_exception(@exception, @status) if @exception
      end

      def args
        [@keyword, @step_match, @multiline_arg, @status, @exception, @source_indent, @background, @file_colon_line]
      end

      def step_name
        @step_match.name
      end

      def step_definition
        @step_match.step_definition
      end

      def step_arguments
        @step_match.step_arguments
      end
    end
  end
end
