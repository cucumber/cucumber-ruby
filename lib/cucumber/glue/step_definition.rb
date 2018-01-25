# frozen_string_literal: true

require 'cucumber/step_match'
require 'cucumber/step_argument'
require 'cucumber/core_ext/string'
require 'cucumber/glue/invoke_in_world'

module Cucumber
  module Glue
    # A Step Definition holds a Regexp pattern and a Proc, and is
    # typically created by calling {Dsl#register_rb_step_definition Given, When or Then}
    # in the step_definitions Ruby files.
    #
    # Example:
    #
    #   Given /I have (\d+) cucumbers in my belly/ do
    #     # some code here
    #   end
    #
    class StepDefinition
      class MissingProc < StandardError
        def message
          'Step definitions must always have a proc or symbol'
        end
      end

      class << self
        def new(registry, string_or_regexp, proc_or_sym, options)
          raise MissingProc if proc_or_sym.nil?
          super registry, registry.create_expression(string_or_regexp), create_proc(proc_or_sym, options)
        end

        private

        def create_proc(proc_or_sym, options)
          return proc_or_sym if proc_or_sym.is_a?(Proc)
          raise ArgumentError unless proc_or_sym.is_a?(Symbol)
          message = proc_or_sym
          target_proc = parse_target_proc_from(options)
          patch_location_onto lambda { |*args|
            target = instance_exec(&target_proc)
            target.send(message, *args)
          }
        end

        def patch_location_onto(block)
          location = Core::Ast::Location.of_caller(5)
          block.define_singleton_method(:source_location) { [location.file, location.line] }
          block
        end

        def parse_target_proc_from(options)
          return lambda { self } unless options.key?(:on)
          target = options[:on]
          case target
          when Proc
            target
          when Symbol
            lambda { self.send(target) }
          else
            lambda { raise ArgumentError, 'Target must be a symbol or a proc' }
          end
        end
      end

      attr_reader :expression, :registry

      def initialize(registry, expression, proc)
        raise 'No regexp' if expression.is_a?(Regexp)
        @registry, @expression, @proc = registry, expression, proc
        # @registry.available_step_definition(regexp_source, location)
      end

      # @api private
      def to_hash
        type = expression.is_a?(CucumberExpressions::RegularExpression) ? 'regular expression' : 'cucumber expression'
        regexp = expression.regexp
        flags = ''
        flags += 'm' if (regexp.options & Regexp::MULTILINE) != 0
        flags += 'i' if (regexp.options & Regexp::IGNORECASE) != 0
        flags += 'x' if (regexp.options & Regexp::EXTENDED) != 0
        {
          source: {
            type: type,
            expression: expression.source
          },
          regexp: {
            source: regexp.source,
            flags: flags
          }
        }
      end

      # @api private
      def ==(step_definition)
        expression.source == step_definition.expression.source
      end

      # @api private
      def arguments_from(step_name)
        args = @expression.match(step_name)
        # @registry.invoked_step_definition(regexp_source, location) if args
        args
      end

      # @api private
      # TODO: inline this and step definition just be a value object
      def invoke(args)
        begin
          InvokeInWorld.cucumber_instance_exec_in(@registry.current_world, true, @expression.to_s, *args, &@proc)
        rescue ArityMismatchError => e
          e.backtrace.unshift(self.backtrace_line)
          raise e
        end
      end

      # @api private
      def backtrace_line
        "#{location}:in `#{@expression}'"
      end

      # @api private
      def file_colon_line
        case @proc
        when Proc
          location.to_s
        when Symbol
          ":#{@proc}"
        end
      end

      # The source location where the step definition can be found
      def location
        @location ||= Cucumber::Core::Ast::Location.from_source_location(*@proc.source_location)
      end

      # @api private
      def file
        @file ||= location.file
      end
    end
  end
end
