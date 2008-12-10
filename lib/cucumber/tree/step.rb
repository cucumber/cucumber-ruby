module Cucumber
  module Tree
    class BaseStep
      attr_reader :scenario
      attr_accessor :error

      def self.new_id!
        @next_id ||= -1
        @next_id += 1
      end

      attr_reader :error

      def file
        @scenario.file
      end

      def steps
        self
      end
      
      def length
        keyword.jlength + 1 + name.jlength
      end

      if defined?(JRUBY_VERSION)
        PENDING_ADJUSTMENT = 2
        REGULAR_ADJUSTMENT = 1
      else
        PENDING_ADJUSTMENT = 3
        REGULAR_ADJUSTMENT = 2
      end

      def execute_in(world, regexp, args, proc)
        strip_pos = nil
        begin
          proc.call_in(world, *args)
        rescue ArityMismatchError => e
          e.backtrace[0] = proc.to_backtrace_line
          strip_pos = e.backtrace.index("#{__FILE__}:#{__LINE__ - 3}:in `execute_in'")
          format_error(strip_pos, proc, e)
        rescue => e
          method_line = "#{__FILE__}:#{__LINE__ - 6}:in `execute_in'"

          # IronRuby returns nil for backtrace...
          if e.backtrace.nil?
            def e.backtrace
              @cucumber_backtrace ||= []
            end
          end

          method_line_pos = e.backtrace.index(method_line)
          if method_line_pos
            strip_pos = method_line_pos - (Pending === e ? PENDING_ADJUSTMENT : REGULAR_ADJUSTMENT) 
          else
            # This happens with rails, because they screw up the backtrace
            # before we get here (injecting erb stacktrace and such)
          end
          format_error(strip_pos, proc, e)
        end
      end

      def format_error(strip_pos, proc, e)
        @error = e
        # Remove lines underneath the plain text step
        e.backtrace[strip_pos..-1] = nil unless strip_pos.nil?
        e.backtrace.flatten
        # Replace the step line with something more readable
        e.backtrace.replace(e.backtrace.map{|l| l.gsub(/`#{proc.meth}'/, "`#{keyword} #{proc.name}'")})
        if row?
          e.backtrace << "#{file}:#{line}:in `#{proc.name}'"
        else
          e.backtrace << "#{file}:#{line}:in `#{keyword} #{name}'"
        end
        raise e
      end

      def id
        @id ||= self.class.new_id!
      end
      
      def actual_keyword
        keyword == Cucumber.language['and'] ? previous_step.actual_keyword : keyword
      end
      
      def previous_step
        @scenario.previous_step(self)
      end
      
      def padding_length
        @scenario.step_padding_length(self)
      end

      def forced_to_pending?
        @error.kind_of?(ForcedPending)
      end
      
      def outline?
        false
      end
    end
    
    class Step < BaseStep
      attr_reader :keyword, :name, :line
      attr_accessor :arity, :extra_args

      def row?
        false
      end

      def initialize(scenario, keyword, name, line)
        @scenario, @keyword, @name, @line = scenario, keyword, name, line
        @extra_args ||= []
        @arity = 0
      end

      def regexp_args_proc(step_mother)
        regexp, args, proc = step_mother.regexp_args_proc(name)
        @arity = args.length
        [regexp, (args + extra_args), proc]
      end

      def format(regexp, format=nil, &proc)
        regexp.nil? ? name : name.gzub(regexp, format, &proc)
      end
    end

    class StepOutline < Step
      def outline?
        true
      end
    end

    class RowStep < BaseStep
      attr_reader :keyword

      def initialize(scenario, step, args)
        @scenario, @step, @args = scenario, step, args
      end
      
      def regexp_args_proc(step_mother)
        regexp, _, proc = @step.regexp_args_proc(step_mother)
        [regexp, @args, proc]
      end
      
      def row?
        true
      end

      def line
        @scenario.line
      end
    end

    class RowStepOutline < Step
      attr_reader :visible_args
      
      def initialize(scenario, step, name, visible_args, line)
        @visible_args = visible_args
        @extra_args = step.extra_args
        super(scenario, keyword, name, line)
      end

      def row?
        true
      end

      def outline?
        true
      end
    end
  end
end