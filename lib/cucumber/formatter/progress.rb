require 'cucumber/formatter/console'
require 'cucumber/formatter/io'
require 'cucumber/formatter/duration_extractor'

module Cucumber
  module Formatter
    # The formatter used for <tt>--format progress</tt>
    class Progress
      include Console
      include Io
      attr_reader :runtime

      def initialize(runtime, path_or_io, options)
        @runtime, @io, @options = runtime, ensure_io(path_or_io, "progress"), options
        @previous_step_keyword = nil
        @snippets_input = []
        @total_duration = 0
      end

      def before_test_case(_test_case)
        unless @profile_information_printed
          print_profile_information
          @profile_information_printed = true
        end
        @previous_step_keyword = nil
      end

      def after_test_step(test_step, result)
        progress(result.to_sym) if !hook?(test_step.source.last) || result.failed?
        collect_snippet_data(test_step, result) unless hook?(test_step.source.last) 
      end

      def after_test_case(_test_case, result)
        @total_duration += DurationExtractor.new(result).result_duration
      end

      def done
        @io.puts
        @io.puts
        print_summary
      end

      private

      def hook?(step)
        ['Before hook', 'After hook', 'AfterStep hook'].include? step.name
      end

      def print_summary
        print_steps(:pending)
        print_steps(:failed)
        print_stats(@total_duration, @options)
        print_snippets(@options)
        print_passing_wip(@options)
      end

      CHARS = {
        :passed    => '.',
        :failed    => 'F',
        :undefined => 'U',
        :pending   => 'P',
        :skipped   => '-'
      }

      def progress(status)
        char = CHARS[status]
        @io.print(format_string(char, status))
        @io.flush
      end

      def table_header_cell?(status)
        status == :skipped_param
      end
    end
  end
end
