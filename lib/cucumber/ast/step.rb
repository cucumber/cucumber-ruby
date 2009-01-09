require 'cucumber/step_definition'
require 'cucumber/core_ext/string'

module Cucumber
  module Ast
    class Step
      ARGUMENT_START = '<'
      ARGUMENT_END  = '>'
      
      attr_writer :scenario, :status

      def initialize(gwt, name, *multiline_args)
        @gwt, @name, @multiline_args = gwt, name, multiline_args
      end

      def execute(world, previous, visitor)
        _execute(@name, @multiline_args, world, previous, visitor)
      end

      def execute_with_arguments(arguments, world, previous, visitor)
        arguments = delimit_argument_names(arguments)
        name = replace_name_arguments(arguments)
        multiline_args = replace_multiline_args_arguments(arguments)
      
        _execute(name, multiline_args, world, previous, visitor)
      end

      def accept(visitor)
        visitor.visit_step_name(@gwt, @name, @status, @step_invocation, comment_padding)
        @multiline_args.each do |inline_arg|
          visitor.visit_inline_arg(inline_arg, @status)
        end
        visitor.visit_step_exception(@exception) if @exception
      end

      def to_sexp
        [:step, @gwt, @name, *@multiline_args.map{|arg| arg.to_sexp}]
      end

      def comment_padding
        max_length = @scenario.max_step_length
        max_length - text_length
      end

      def text_length
        @gwt.jlength + @name.jlength
      end

      private

      def _execute(name, multiline_args, world, previous, visitor)
        if @status.nil?
          begin
            @step_invocation = visitor.step_invocation(name, world)
            if previous == :passed
              @step_invocation.invoke(*multiline_args)
              @status = :passed
            else
              @status = :skipped
            end
          rescue StepMom::Undefined
            @status = :undefined
          rescue StepMom::Pending
            @status = :pending
          rescue Exception => exception
            @status = :failed
            @exception = exception
          end
        end
        @status
      end
      
      def delimit_argument_names(arguments)
        arguments.inject({}) { |h,(k,v)| h["#{ARGUMENT_START}#{k}#{ARGUMENT_END}"] = v; h }
      end
      
      def replace_name_arguments(arguments)
        name_with_arguments_replaced = @name
        arguments.each do |name, value|
          name_with_arguments_replaced = name_with_arguments_replaced.gsub(name, value)
        end
        name_with_arguments_replaced
      end

      def replace_multiline_args_arguments(arguments)
        @multiline_args.map do |arg|
          arg.arguments_replaced(arguments)
        end
      end
      
    end
  end
end
