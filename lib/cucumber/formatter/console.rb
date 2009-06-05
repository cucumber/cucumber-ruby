require 'cucumber/formatter/ansicolor'
require 'cucumber/formatter/duration'

module Cucumber
  module Formatter
    module Console
      extend ANSIColor
      include Duration
      
      FORMATS = Hash.new{|hash, format| hash[format] = method(format).to_proc}

      def format_step(keyword, step_match, status, source_indent)
        comment = if source_indent
          c = (' # ' + step_match.file_colon_line).indent(source_indent)
          format_string(c, :comment)
        else
          ''
        end

        format = format_for(status, :param)
        line = keyword + " " + step_match.format_args(format) + comment
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

      def print_steps(status)
        print_elements(step_mother.steps(status), status, 'steps')
      end

      def print_elements(elements, status, kind)
        if elements.any?
          @io.puts(format_string("(::) #{status} #{kind} (::)", status))
          @io.puts
          @io.flush
        end

        elements.each_with_index do |element, i|
          if status == :failed
            print_exception(element.exception, status, 0)
          else
            @io.puts(format_string(element.backtrace_line, status))
          end
          @io.puts
          @io.flush
        end
      end

      def print_counts
        STDERR.puts("The #print_counts method is deprecated and will be removed in 0.4. Use #print_stats instead")
        print_stats(nil)
      end

      def print_stats(features)
        @io.print dump_count(step_mother.scenarios.length, "scenario")
        print_status_counts{|status| step_mother.scenarios(status)}

        @io.print dump_count(step_mother.steps.length, "step")
        print_status_counts{|status| step_mother.steps(status)}

        @io.puts(format_duration(features.duration)) if features

        @io.flush
      end
      
      def print_exception(e, status, indent)
        @io.puts(format_string("#{e.message} (#{e.class})\n#{e.backtrace.join("\n")}".indent(indent), status))
      end

      def print_snippets(options)
        return unless options[:snippets]
        undefined = step_mother.steps(:undefined)
        return if undefined.empty?
        snippets = undefined.map do |step|
          step_name = Undefined === step.exception ? step.exception.step_name : step.name
          step_multiline_class = step.multiline_arg ? step.multiline_arg.class : nil
          snippet = @step_mother.snippet_text(step.actual_keyword, step_name, step_multiline_class)
          snippet
        end.compact.uniq

        text = "\nYou can implement step definitions for undefined steps with these snippets:\n\n"
        text += snippets.join("\n\n")

        @io.puts format_string(text, :undefined)
        @io.puts
        @io.flush
      end

      def print_passing_wip(options)
        return unless options[:wip]
        passed = step_mother.scenarios(:passed)
        if passed.any?
          @io.puts "\nThe --wip switch was used, so I didn't expect anything to pass. These scenarios passed:"
          print_elements(passed, :passed, "scenarios")
        end
      end

      def announce(announcement)
        @io.puts
        @io.puts(format_string(announcement, :tag))
        @io.flush
      end

    private

      def print_status_counts
        counts = [:failed, :skipped, :undefined, :pending, :passed].map do |status|
          elements = yield status
          elements.any? ? format_string("#{elements.length} #{status.to_s}", status) : nil
        end.compact
        if counts.any?
          @io.puts(" (#{counts.join(', ')})")
        else
          @io.puts
        end
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