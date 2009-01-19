require 'cucumber/formatter/ansicolor'

module Cucumber
  module Formatter
    module Console
      extend ANSIColor
      FORMATS = Hash.new{|hash, format| hash[format] = method(format).to_proc}

      def format_step(gwt, step_name, status, step_definition, source_indent)
        line = if step_definition # nil for :outline
          comment = if source_indent
            c = (' # ' + step_definition.file_colon_line).indent(source_indent)
            format_string(c, :comment)
          else
            ''
          end
          gwt + " " + step_definition.format_args(step_name, format_for(status, :param)) + comment
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

      def print_steps(io, features, status)
        steps = status == :undefined ? features.scenarios.select{|scenario| scenario.undefined?} : []
        steps += features.steps[status].dup

        if steps.any?
          io.puts(format_string("(::) #{status} (::)", status))
          io.puts
        end

        steps.each_with_index do |step, i|
          if status == :failed
            print_exception(io, step.exception, 0)
          else
            io.puts(format_string(step.backtrace_line, status))
          end
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

      def print_exception(io, e, indent)
        io.puts(format_string("#{e.message} (#{e.class})\n#{e.backtrace.join("\n")}".indent(indent), :failed))
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