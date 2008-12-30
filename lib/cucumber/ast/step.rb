require 'cucumber/step_definition'
require 'cucumber/core_ext/string'

module Cucumber
  module Ast
    class Step
      def initialize(scenario, status, gwt, name, *multiline_args)
        @scenario, @status, @gwt, @name, @multiline_args = scenario, status, gwt, name, multiline_args
      end

      def execute(world, previous)
        _execute(@name, world, previous)
      end

      def execute_with_arguments(arguments, world, previous)
        name_with_arguments_replaced = @name
        arguments.each do |name, value|
          name_with_arguments_replaced = name_with_arguments_replaced.gsub(/<#{name}>/, value)
        end
        
        _execute(name_with_arguments_replaced, world, previous)
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

      def _execute(name, world, previous)
        if @status.nil?
          begin
            @step_invocation = @scenario.step_invocation(name, world)
            if previous == :passed
              @step_invocation.invoke(*@multiline_args)
              @status = :passed
            else
              @status = :skipped
            end
          rescue StepMom::Missing
            @status = :missing
          rescue StepMom::Pending
            @status = :pending
          rescue Exception => exception
            @status = :failed
            @exception = exception
          end
        end
        @status
      end
    end
  end
end
