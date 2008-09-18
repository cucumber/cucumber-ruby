module Cucumber
  module Tree
    class BaseStep
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
          e.backtrace[0] = proc.backtrace_line
          strip_pos = e.backtrace.index("#{__FILE__}:#{__LINE__ - 3}:in `execute_in'")
          format_error(strip_pos, proc, e)
        rescue => e
          method_line = "#{__FILE__}:#{__LINE__ - 6}:in `execute_in'"
          method_line_pos = e.backtrace.index(method_line)
          if method_line_pos
            strip_pos = method_line_pos - (Pending === e ? PENDING_ADJUSTMENT : REGULAR_ADJUSTMENT) 
          else
            # This happens with rails, because they screw up the backtrace
            # before we get here (injecting erb stactrace and such)
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
    end
    
    class Step < BaseStep
      attr_reader :keyword, :name, :line
      attr_accessor :arity

      def row?
        false
      end

      def initialize(scenario, keyword, name, line)
        @scenario, @keyword, @name, @line = scenario, keyword, name, line
      end

      def regexp_args_proc(step_mother)
        regexp, args, proc = step_mother.regexp_args_proc(name)
        @arity = args.length
        [regexp, args, proc]
      end

      def format(regexp, format=nil, &proc)
        regexp.nil? ? name : name.gzub(regexp, format, &proc)
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

  end
end