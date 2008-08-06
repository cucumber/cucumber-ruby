module Cucumber
  module Tree
    class BaseStep
      def self.new_id!
        @next_id ||= -1
        @next_id += 1
      end

      attr_reader :error
      attr_accessor :args

      def file
        @scenario.file
      end

      def regexp
        @regexp || //
      end

      PENDING = lambda do |*_| 
        raise Pending
      end
      PENDING.extend(CoreExt::CallIn)
      PENDING.name = "PENDING"

      def proc
        @proc || PENDING
      end

      def attach(regexp, proc, args)
        if @regexp
          raise <<-EOM
  "#{name}" matches several step definitions:

  #{@proc.backtrace_line}
  #{proc.backtrace_line}

  Please give your steps unambiguous names
          EOM
        end
        @regexp, @proc, @args = regexp, proc, args
      end

      if defined?(JRUBY_VERSION)
        PENDING_ADJUSTMENT = 2
        REGULAR_ADJUSTMENT = 1
      else
        PENDING_ADJUSTMENT = 3
        REGULAR_ADJUSTMENT = 2
      end

      def execute_in(world)
        strip_pos = nil
        begin
          proc.call_in(world, *@args)
        rescue ArgCountError => e
          e.backtrace[0] = @proc.backtrace_line
          strip_pos = e.backtrace.index("#{__FILE__}:#{__LINE__ - 3}:in `execute_in'")
          format_error(strip_pos, e)
        rescue => e
          method_line = "#{__FILE__}:#{__LINE__ - 6}:in `execute_in'"
          method_line_pos = e.backtrace.index(method_line)
          if method_line_pos
            strip_pos = method_line_pos - (Pending === e ? PENDING_ADJUSTMENT : REGULAR_ADJUSTMENT) 
          else
            # This happens with rails, because they screw up the backtrace
            # before we get here (injecting erb stactrace and such)
          end
          format_error(strip_pos, e)
        end
      end

      def format_error(strip_pos, e)
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
    end
    
    class Step < BaseStep
      attr_accessor :error

      def row?
        false
      end

      def initialize(scenario, keyword, name, line)
        @scenario, @keyword, @name, @line = scenario, keyword, name, line
#        @file, @line, _ = *caller[2].split(':')
        @args = []
      end

      def gzub(format=nil, &proc)
        name.gzub(regexp, format, &proc)
      end

      attr_reader :keyword, :name, :line
    end

    class RowStep < BaseStep
      attr_reader :keyword

      def initialize(scenario, keyword, proc, args)
        @scenario, @keyword, @proc, @args = scenario, keyword, proc, args
      end

      def gzub(format=nil, &proc)
        raise "WWW"
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