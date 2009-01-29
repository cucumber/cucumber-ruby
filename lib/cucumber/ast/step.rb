require 'cucumber/step_definition'
require 'cucumber/core_ext/string'

module Cucumber
  module Ast
    class Step
      attr_reader :keyword, :name
      attr_writer :world, :previous, :options
      attr_accessor :status, :scenario, :exception

      def initialize(line, keyword, name, *multiline_args)
        @line, @keyword, @name, @multiline_args = line, keyword, name, multiline_args
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
        execute(visitor)

        if @status == :outline
          step_definition = find_first_name_and_step_definition_from_examples(visitor)
        else
          step_definition = @step_definition
        end
        visitor.visit_step_name(@keyword, @name, @status, step_definition, source_indent)
        @multiline_args.each do |multiline_arg|
          visitor.visit_multiline_arg(multiline_arg, @status)
        end
        @exception
      end

      def find_first_name_and_step_definition_from_examples(visitor)
        # @scenario is always a ScenarioOutline in this case
        @scenario.each_example_row do |cells|
          argument_hash       = cells.to_hash
          delimited_arguments = delimit_argument_names(argument_hash)
          name                = replace_name_arguments(delimited_arguments)
          step_definition     = visitor.step_definition(name) rescue nil
          return step_definition if step_definition
        end
        nil
      end

      def to_sexp
        [:step, @line, @keyword, @name, *@multiline_args.map{|arg| arg.to_sexp}]
      end

      def at_lines?(lines)
        lines.empty? || lines.index(@line) || @multiline_args.detect{|a| a.at_lines?(lines)}
      end

      def source_indent
        @scenario.source_indent(text_length)
      end

      def text_length
        @keyword.jlength + @name.jlength + 2 # Add 2 because steps get indented 2 more than scenarios
      end

      def backtrace_line
        @backtrace_line ||= @scenario.backtrace_line("#{@keyword} #{@name}", @line) unless @scenario.nil?
      end

      def file_line
        @file_line ||= @scenario.file_line(@line) unless @scenario.nil?
      end

      def actual_keyword
        if [Cucumber.keyword_hash['and'], Cucumber.keyword_hash['but']].index(@keyword) && previous_step
          previous_step.actual_keyword
        else
          @keyword
        end
      end

      protected

      def previous_step
        @scenario.previous_step(self)
      end

      private

      def execute(visitor)
        matched_args = []
        if @status.nil?
          begin
            @step_definition = visitor.step_definition(@name)
            matched_args = @step_definition.matched_args(@name)
            if @previous == :passed && !visitor.options[:dry_run]
              @world.__cucumber_current_step = self
              @step_definition.execute(@name, @world, *(matched_args + @multiline_args))
              @status = :passed
            else
              @status = :skipped
            end
          rescue Undefined => exception
            if visitor.options[:strict]
              exception.set_backtrace([])
              failed(exception)
            else
              @status = :undefined
            end
          rescue Pending => exception
            visitor.options[:strict] ? failed(exception) : @status = :pending
          rescue Exception => exception
            failed(exception)
          end
          @scenario.step_executed(self) if @scenario
        end
        [self, @status, matched_args]
      end

      def execute_twin(world, previous, visitor, line, name, *multiline_args)
        # We'll create a new step and execute that
        step = Step.new(line, @keyword, name, *multiline_args)
        step.scenario = @scenario
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
