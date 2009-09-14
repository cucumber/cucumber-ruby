require 'cucumber/formatter/console'

module Cucumber
  module Formatter
    # The formatter used for <tt>--format progress</tt>
    class Progress
      include Console
      attr_reader :step_mother

      def initialize(step_mother, io, options)
        @step_mother, @io, @options = step_mother, io, options
      end

      def after_visit_features(features)
        @io.puts
        @io.puts
        print_summary(features)
      end

      def before_visit_feature_element(feature_element)
        record_tag_occurrences(feature_element, @options)
      end

      def after_visit_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        progress(status)
        @status = status
      end

      # def after_visit_table_cell_value(value, status)
      #   status ||= @status
      #   progress(status) unless table_header_cell?(status)
      # end

      private

      def print_summary(features)
        print_steps(:pending)
        print_steps(:failed)
        print_stats(features)
        print_snippets(@options)
        print_passing_wip(@options)
        print_tag_limit_warnings(@options)
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
