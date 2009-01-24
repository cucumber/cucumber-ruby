require 'cucumber/formatter/ansicolor'

module Cucumber
  module Formatter
    module Console
      extend ANSIColor
      FORMATS = Hash.new{|hash, format| hash[format] = method(format).to_proc}

      def format_step(keyword, step_name, status, step_definition, source_indent)
        line = if step_definition # nil for :outline
          comment = if source_indent
            c = (' # ' + step_definition.file_colon_line).indent(source_indent)
            format_string(c, :comment)
          else
            ''
          end
          keyword + " " + step_definition.format_args(step_name, format_for(status, :param)) + comment
        else
          keyword + " " + step_name
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
        status = Cucumber::EXCEPTION_STATUS[e.class]
        io.puts(format_string("#{e.message} (#{e.class})\n#{e.backtrace.join("\n")}".indent(indent), status))
      end

      def print_snippets(io, features, options)
        return unless options[:snippets]
        undefined = features.steps[:undefined]
        return if undefined.empty?
        snippets = undefined.map do |step|
          step_name = StepMother::Undefined === step.exception ? step.exception.step_name : step.name
          snippet = "#{step.actual_keyword} /^#{escape_regexp_characters(step_name)}$/ do\nend"
          snippet
        end.compact.uniq

        text = "\nYou can implement step definitions for missing steps with these snippets:\n\n"
        text += snippets.join("\n\n")
        @io.puts format_string(text, :undefined)
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

      def escape_regexp_characters(string)
        Regexp.escape(string).gsub('\ ', ' ').gsub('/', '\/') unless string.nil?
      end
    end
  end
end