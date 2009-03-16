require 'cucumber/formatter/console'

module Cucumber
  module Formatter
    class Progress < Ast::Visitor
      include Console

      def initialize(step_mother, io, options)
        super(step_mother)
        @io = io
        @options = options
      end

      def visit_features(features)
        super
        @io.puts
        @io.puts
        print_summary
      end

      def visit_multiline_arg(multiline_arg)
        @multiline_arg = true
        super
        @multiline_arg = false
      end

      def visit_step_name(keyword, step_match, status, source_indent, background)
        progress(status) unless status == :outline
      end

      def visit_table_cell_value(value, width, status)
        progress(status) if (status != :thead) && !@multiline_arg
      end

      private

      def print_summary
        print_steps(:pending)
        print_steps(:failed)
        print_counts
        print_snippets(@options)
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
      
    end
  end
end
