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

      attr_reader :proc, :regexp

      def initialize(rb_language, regexp, proc)
        raise MissingProc if proc.nil?
        if String === regexp
          p = regexp.gsub(/\$\w+/, '(.*)') # Replace $var with (.*)
          regexp = Regexp.new("^#{p}$") 
        end
        @rb_language, @regexp, @proc = rb_language, regexp, proc
      end

      def ==(step_definition)
        self.regexp == step_definition.regexp
      end

      def groups(step_name)
        match = regexp.match(step_name)
        if match
          n = 0
          match.captures.map do |val|
            n += 1
            RbGroup.new(val, match.offset(n)[0])
          end
        else
          nil
        end
      end

      def invoke(args)
        args = args.map{|arg| Ast::PyString === arg ? arg.to_s : arg}
        begin
          args = @rb_language.execute_transforms(args)
          @rb_language.current_world.cucumber_instance_exec(true, regexp.inspect, *args, &@proc)
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
