require 'cucumber/formatter/ansicolor'

module Cucumber
  module Formatter
    module Console
      extend ANSIColor
      FORMATS = Hash.new{|hash, format| hash[format] = method(format).to_proc}

      def format_step(gwt, step_name, status, step_invocation, source_indent)
        line = if step_invocation # nil for :outline
          comment = if source_indent
            c = (' # ' + step_invocation.file_colon_line).indent(source_indent)
            format_string(c, :comment)
          else
            ''
          end
          gwt + " " + step_invocation.format_args(format_for(status, :param)) + comment
        else
          gwt + " " + step_name
        end
        format_string(line, status)
      end

      def format_string(string, status)
        fmt = format_for(status)
        if Proc === fmt
          fmt.call(string)
        else
          fmt % string
        end
      end

      def print_summary(io, features)
        print_exceptions(io, features)

        pending_count = features.scenarios.select{|scenario| scenario.pending?}.length
        if pending_count > 0
          pending_count_string = dump_count(pending_count, "scenario", "pending")
          io.puts format_string(pending_count_string, :pending)
        end
        
        print_counts(io, features)
      end

      def print_exceptions(io, features)
        features.steps[:failed].each_with_index do |step, i|
          print_exception(io, step.exception, "#{i+1}) ", 0)
          io.puts
        end
      end

      def print_counts(io, features)
        io.puts dump_count(features.scenarios.length, "scenario")

        [:failed, :skipped, :undefined, :pending, :passed].each do |status|
          if features.steps[status].any?
            count_string = dump_count(features.steps[status].length, "step", status.to_s)
            io.puts format_string(count_string, status)
          end
        end
      end

      def print_exception(io, e, prefix, indent)
        io.puts(format_string("#{prefix}#{e.message} (#{e.class})\n#{e.backtrace.join("\n")}".indent(indent), :failed))
      end

    private

      def dump_count(count, what, state=nil)
        [count, "#{what}#{count == 1 ? '' : 's'}", state].compact.join(" ")
      end

      def format_for(*keys)
        key = keys.join('_').to_sym
        fmt = FORMATS[key]
        raise "No format for #{key.inspect}: #{FORMATS.inspect}" if fmt.nil?
        fmt
      end
    end
  end
end