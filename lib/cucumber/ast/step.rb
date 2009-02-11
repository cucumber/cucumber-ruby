require 'cucumber/step_definition'
require 'cucumber/core_ext/string'

module Cucumber
  module Ast
    class Step
      attr_reader :keyword, :name, :multiline_args
      attr_writer :step_collection, :options
      attr_accessor :feature_element, :exception

      def initialize(line, keyword, name, *multiline_args)
        @line, @keyword, @name, @multiline_args = line, keyword, name, multiline_args
      end

      def invoke(step_match, world)
        step_match.invoke(world, @multiline_args)
      end

      def execute_with_arguments(argument_hash, world, previous, visitor, row_line)
        delimited_arguments = delimit_argument_names(argument_hash)
        name                = replace_name_arguments(delimited_arguments)
        multiline_args      = replace_multiline_args_arguments(delimited_arguments)

        execute_twin(world, previous, visitor, row_line, name, *multiline_args)
      end
      
      def execute_as_new(world, previous, visitor, row_line)
        execute_twin(world, previous, visitor, row_line, @name, *@multiline_args)
      end

      def accept(visitor)
        # The only time a Step is visited is when it is in a ScenarioOutline.
        # Otherwise it's always StepInvocation that gest visited instead.
        visit_step_name(visitor, first_match(visitor), nil)
      end
      
      def visit_step_name(visitor, step_match, exception)
        visitor.visit_step_name(@keyword, step_match, exception, source_indent)
        @multiline_args.each do |multiline_arg|
          visitor.visit_multiline_arg(multiline_arg, status)
        end
      end

      def first_match(visitor)
        # @feature_element is always a ScenarioOutline in this case
        @feature_element.each_example_row do |cells|
          argument_hash       = cells.to_hash
          delimited_arguments = delimit_argument_names(argument_hash)
          name                = replace_name_arguments(delimited_arguments)
          step_match          = visitor.step_match(name) rescue nil
          return step_match if step_match
        end
        StepMatch.new(nil, @name, []) # Didn't find any
      end

      def to_sexp
        [:step, @line, @keyword, @name, *@multiline_args.map{|arg| arg.to_sexp}]
      end

      def at_lines?(lines)
        lines.empty? || lines.index(@line) || @multiline_args.detect{|a| a.at_lines?(lines)}
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

      def file_line
        @file_line ||= @feature_element.file_line(@line) unless @feature_element.nil?
      end

      def actual_keyword
        if [Cucumber.keyword_hash['and'], Cucumber.keyword_hash['but']].index(@keyword) && previous_step
          previous_step.actual_keyword
        else
          @keyword
        end
      end

      protected

      # TODO: Refactor when we use StepCollection everywhere
      def previous_step
        @feature_element.previous_step(self)
      end

      private

      def execute_twin(world, previous, visitor, line, name, *multiline_args)
        # We'll create a new step and execute that
        step = Step.new(line, @keyword, name, *multiline_args)
        step.feature_element = @feature_element
        step.world    = world
        step.previous = previous
        step.__send__(:execute, visitor)
      end

      ARGUMENT_START = '<'
      ARGUMENT_END   = '>'

      def delimit_argument_names(argument_hash)
        argument_hash.inject({}) { |h,(k,v)| h["#{ARGUMENT_START}#{k}#{ARGUMENT_END}"] = v; h }
      end

      def replace_name_arguments(argument_hash)
        name_with_arguments_replaced = @name
        argument_hash.each do |name, value|
          name_with_arguments_replaced = name_with_arguments_replaced.gsub(name, value) if value
        end
        name_with_arguments_replaced
      end

      def replace_multiline_args_arguments(arguments)
        @multiline_args.map do |arg|
          arg.arguments_replaced(arguments)
        end
      end

      def failed(exception)
        @status = :failed
        @exception = exception
        @exception.backtrace << backtrace_line unless backtrace_line.nil?
      end
    end
  end
end
