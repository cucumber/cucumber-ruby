require 'cucumber/formatter/ansicolor'

module Cucumber
  module Formatter
    module Console
      extend ANSIColor
      FORMATS = Hash.new{|hash, format| hash[format] = method(format).to_proc}

      def format_step(keyword, step_name, status, step_definition, source_indent)
        comment = if source_indent && step_definition
          c = (' # ' + step_definition.file_colon_line).indent(source_indent)
          format_string(c, :comment)
        else
          ''
        end

        begin
          line = keyword + " " + step_definition.format_args(step_name, format_for(status, :param)) + comment
        rescue
          # It didn't match. This often happens for :outline steps
          line = keyword + " " + step_name + comment
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

      def print_undefined_scenarios(features)
        elements = features.scenarios.select{|scenario| scenario.undefined?}
        print_elements(elements, :undefined, 'scenarios')
      end

      def print_steps(features, status)
        print_elements(features.steps[status], status, 'steps')
      end

      def print_elements(elements, status, kind)
        if elements.any?
          @io.puts(format_string("(::) #{status} #{kind} (::)", status))
          @io.puts
          @io.flush
        end

        elements.each_with_index do |element, i|
          if status == :failed
            print_exception(element.exception, 0)
          else
            @io.puts(format_string(element.backtrace_line, status))
          end
          @io.puts
          @io.flush
        end
      end

      def print_counts(features)
        @io.puts dump_count(features.scenarios.length, "scenario")

        [:failed, :skipped, :undefined, :pending, :passed].each do |status|
          if features.steps[status].any?
            count_string = dump_count(features.steps[status].length, "step", status.to_s)
            @io.puts format_string(count_string, status)
            @io.flush
          end
        end
      end

      def print_exception(e, indent)
        status = Cucumber::EXCEPTION_STATUS[e.class]
        @io.puts(format_string("#{e.message} (#{e.class})\n#{e.backtrace.join("\n")}".indent(indent), status))
      end

      def print_snippets(features, options)
        return unless options[:snippets]
        undefined = features.steps[:undefined]
        return if undefined.empty?
        snippets = undefined.map do |step|
          step_name = Undefined === step.exception ? step.exception.step_name : step.name
          snippet = @step_mother.snippet_text(step.actual_keyword, step_name)
          snippet
        end.compact.uniq

        text = "\nYou can implement step definitions for missing steps with these snippets:\n\n"
        text += snippets.join("\n\n")

        @io.puts format_string(text, :undefined)
        @io.puts
        @io.flush
      end

    private

      def with_color
        c = Term::ANSIColor.coloring?
        Term::ANSIColor.coloring = @io.tty?
        yield
        Term::ANSIColor.coloring = c
      end

      def dump_count(count, what, state=nil)
        [count, state, "#{what}#{count == 1 ? '' : 's'}"].compact.join(" ")
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