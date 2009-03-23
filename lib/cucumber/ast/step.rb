require 'cucumber/step_definition'
require 'cucumber/core_ext/string'

module Cucumber
  module Ast
    class Step
      attr_reader :line, :keyword, :name, :multiline_arg
      attr_writer :step_collection, :options
      attr_accessor :feature_element, :exception

      def initialize(line, keyword, name, multiline_arg=nil)
        @line, @keyword, @name, @multiline_arg = line, keyword, name, multiline_arg
      end

      def background?
        false
      end

      def step_invocation
        StepInvocation.new(self, @name, @multiline_arg, [])
      end

      def step_invocation_from_cells(cells)
        matched_cells = matched_cells(cells)

        delimited_arguments = delimit_argument_names(cells.to_hash)
        name                = replace_name_arguments(delimited_arguments)
        multiline_arg       = @multiline_arg.nil? ? nil : @multiline_arg.arguments_replaced(delimited_arguments)

        StepInvocation.new(self, name, multiline_arg, matched_cells)
      end

      def accept(visitor)
        # The only time a Step is visited is when it is in a ScenarioOutline.
        # Otherwise it's always StepInvocation that gest visited instead.
        visit_step_details(visitor, first_match(visitor), @multiline_arg, :skipped, nil, nil)
      end
      
      def visit_step_details(visitor, step_match, multiline_arg, status, exception, background)
        visitor.visit_step_name(@keyword, step_match, status, source_indent, background)
        visitor.visit_multiline_arg(@multiline_arg) if @multiline_arg
        visitor.visit_exception(exception, status) if exception
      end

      def first_match(visitor)
        # @feature_element is always a ScenarioOutline in this case
        @feature_element.each_example_row do |cells|
          argument_hash       = cells.to_hash
          delimited_arguments = delimit_argument_names(argument_hash)
          name                = replace_name_arguments(delimited_arguments)
          step_match          = visitor.step_mother.step_match(name, @name) rescue nil
          return step_match if step_match
        end
        NoStepMatch.new(self)
      end

      def to_sexp
        [:step, @line, @keyword, @name, (@multiline_arg.nil? ? nil : @multiline_arg.to_sexp)].compact
      end

      def matches_lines?(lines)
        lines.index(@line) || (@multiline_arg && @multiline_arg.matches_lines?(lines))
      end

      def source_indent
        @feature_element.source_indent(text_length)
      end

      def text_length
        @keyword.jlength + @name.jlength + 2 # Add 2 because steps get indented 2 more than scenarios
      end

      def backtrace_line
        @backtrace_line ||= @feature_element.backtrace_line("#{@keyword} #{@name}", @line) unless @feature_element.nil?
      end

      def file_colon_line
        @file_colon_line ||= @feature_element.file_colon_line(@line) unless @feature_element.nil?
      end

      def dom_id
        @dom_id ||= file_colon_line.gsub(/\//, '_').gsub(/\./, '_').gsub(/:/, '_')
      end

      private

      def matched_cells(cells)
        cells.select do |cell|
          @name.index(delimited(cell.header_cell.value))
        end
      end

      def delimit_argument_names(argument_hash)
        argument_hash.inject({}) { |h,(name,value)| h[delimited(name)] = value; h }
      end

      def delimited(s)
        "<#{s}>"
      end

      def replace_name_arguments(argument_hash)
        name_with_arguments_replaced = @name
        argument_hash.each do |name, value|
          value ||= ''
          name_with_arguments_replaced = name_with_arguments_replaced.gsub(name, value) if value
        end
        name_with_arguments_replaced
      end
    end
  end
end
