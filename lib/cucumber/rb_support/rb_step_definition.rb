require 'cucumber/step_match'
require 'cucumber/core_ext/string'
require 'cucumber/core_ext/proc'
require 'cucumber/rb_support/rb_group'

module Cucumber
  module RbSupport
    # A Ruby Step Definition holds a Regexp and a Proc, and is created
    # by calling <tt>Given</tt>, <tt>When</tt> or <tt>Then</tt>
    # in the <tt>step_definitions</tt> ruby files. See also RbDsl.
    #
    # Example:
    #
    #   Given /I have (\d+) cucumbers in my belly/ do
    #     # some code here
    #   end
    #
    class RbStepDefinition
      include LanguageSupport::StepDefinitionMethods

      class MissingProc < StandardError
        def message
          "Step definitions must always have a proc"
        end
      end

      def initialize(rb_language, regexp, proc)
        raise MissingProc if proc.nil?
        if String === regexp
          p = regexp.gsub(/\$\w+/, '(.*)') # Replace $var with (.*)
          regexp = Regexp.new("^#{p}$") 
        end
        @rb_language, @regexp, @proc = rb_language, regexp, proc
      end

      def regexp_source
        @regexp.inspect
      end

      def ==(step_definition)
        regexp_source == step_definition.regexp_source
      end

      def groups(step_name)
        RbGroup.groups_from(@regexp, step_name)
      end

      def invoke(args)
        args = args.map{|arg| Ast::PyString === arg ? arg.to_s : arg}
        begin
          args = @rb_language.execute_transforms(args)
          @rb_language.current_world.cucumber_instance_exec(true, regexp_source, *args, &@proc)
        rescue Cucumber::ArityMismatchError => e
          e.backtrace.unshift(self.backtrace_line)
          raise e
        end
      end

      def file_colon_line
        @proc.file_colon_line
      end
    
      def file
        @file ||= file_colon_line.split(':')[0]
      end
    end
  end
end
