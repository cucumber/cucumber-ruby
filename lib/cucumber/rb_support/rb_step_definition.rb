require 'cucumber/step_match'
require 'cucumber/core_ext/string'
require 'cucumber/core_ext/proc'
require 'cucumber/rb_support/regexp_argument_matcher'

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

      class MissingProc < StandardError
        def message
          "Step definitions must always have a proc or symbol"
        end
      end

      class << self
        def new(rb_language, pattern, proc_or_sym, options)
          raise MissingProc if proc_or_sym.nil?
          case pattern
          when String
            TurnipStyle.new(rb_language, pattern, create_proc(proc_or_sym, options))
          when Regexp
            RegexpStyle.new rb_language, pattern, create_proc(proc_or_sym, options)
          else
            raise ArgumentError, "Step definitions must be defined with a String or a Regexp"
          end
        end

        private
        def create_proc(proc_or_sym, options)
          return proc_or_sym if proc_or_sym.is_a?(Proc)
          raise ArgumentError unless proc_or_sym.is_a?(Symbol)
          message = proc_or_sym
          target_proc = parse_target_proc_from(options)
          lambda do |*args|
            target = instance_exec(&target_proc)
            target.send(message, *args)
          end
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
            lambda { raise ArgumentError, "Target must be a symbol or a proc" }
          end
        end
      end

      class RegexpStyle

        def initialize(rb_language, regexp, proc)
          @rb_language, @regexp, @proc = rb_language, regexp, proc
          @rb_language.available_step_definition(regexp_source, file_colon_line)
        end

        def regexp_source
          @regexp.inspect
        end

        def to_hash
          flags = ''
          flags += 'm' if (@regexp.options & Regexp::MULTILINE) != 0
          flags += 'i' if (@regexp.options & Regexp::IGNORECASE) != 0
          flags += 'x' if (@regexp.options & Regexp::EXTENDED) != 0
          {'source' => @regexp.source, 'flags' => flags}
        end

        def ==(step_definition)
          regexp_source == step_definition.regexp_source
        end

        def arguments_from(step_name)
          args = RegexpArgumentMatcher.arguments_from(@regexp, step_name)
          @rb_language.invoked_step_definition(regexp_source, file_colon_line) if args
          args
        end

        def invoke(args)
          begin
            args = @rb_language.execute_transforms(args)
            @rb_language.current_world.cucumber_instance_exec(true, regexp_source, *args, &@proc)
          rescue Cucumber::ArityMismatchError => e
            e.backtrace.unshift(self.backtrace_line)
            raise e
          end
        end

        def backtrace_line
          @proc.backtrace_line(regexp_source)
        end

        def file_colon_line
          case @proc
          when Proc
            @proc.file_colon_line
          when Symbol
            ":#{@proc}"
          end
        end

        def file
          @file ||= file_colon_line.split(':')[0]
        end
      end

      class TurnipStyle < RegexpStyle

        def initialize(rb_language, pattern, proc)
          @pattern = pattern
          super rb_language, compile_regexp(@pattern), proc
        end

        def regexp_source
          @pattern.inspect
        end

        def arguments_from(step_name)
          args = TurnipArguments.match(@regexp, step_name)
          @rb_language.invoked_step_definition(regexp_source, file_colon_line) if args
          args
        end

        class TurnipArguments
          def self.match(regexp, step_name)
            match = regexp.match(step_name)
            if match
              [new(match)].select(&:with_arguments?)
            else
              nil
            end
          end

          def initialize(match)
            @match = match
          end

          def with_arguments?
            @match.names.any?
          end

          def method_missing(method_name, *arguments, &block)
            if @match.names.include?(String(method_name))
              extract_capture(@match[method_name])
            else
              super
            end
          end

          def val
            self
          end

          def offset
            nil
          end

          private
          def extract_capture(capture)
            capture.scan(/(?-:"([^"]*)"|'([^']*)'|([[:alnum:]_-]+))/).flatten.compact.first
          end
        end


        private
        OPTIONAL_WORD_REGEXP = /(\\\s)?\\\(([^)]+)\\\)(\\\s)?/
        PLACEHOLDER_REGEXP = /:([\w]+)/
        ALTERNATIVE_WORD_REGEXP = /([[:alpha:]]+)((\/[[:alpha:]]+)+)/

        def compile_regexp(pattern)
          @placeholder_names = []
          regexp = Regexp.escape(pattern)

          regexp.gsub!(PLACEHOLDER_REGEXP) do |_|
            @placeholder_names << "#{$1}"
            "(?<#{$1}>#{/(?-:"([^"]*)"|'([^']*)'|([[:alnum:]_-]+))/.source})"
          end

          regexp.gsub!(OPTIONAL_WORD_REGEXP) do |_|
            [$1, $2, $3].compact.map { |m| "(?:#{m})?" }.join
          end

          regexp.gsub!(ALTERNATIVE_WORD_REGEXP) do |_|
            "(?:#{$1}#{$2.tr('/', '|')})"
          end

          Regexp.new("^#{regexp}$")
        end
      end
    end

  end
end
