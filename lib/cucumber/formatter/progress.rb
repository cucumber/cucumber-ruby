require 'cucumber/formatter/console'

module Cucumber
  module Formatter
    class Progress < Ast::Visitor
      include Console

      def initialize(step_mother, io, options)
        super(step_mother)
        @io = (io == STDOUT) ? Kernel : io
        @options = options
      end

      def visit_features(features)
        super
        @io.puts
        @io.puts
        print_summary(@io, features)
      end

      def visit_multiline_arg(multiline_arg, status)
        @multiline_arg = true
        super
        @multiline_arg = false
      end

      def visit_feature_element(feature_element)
        @io.print(pending("S")) if feature_element.pending?
        super
      end

      def visit_step_name(gwt, step_name, status, step_invocation, comment_padding)
        progress(status) unless status == :outline
      end

      def visit_table_cell_value(value, width, status)
        progress(status) if (status != :thead) && !@multiline_arg
      end
      
    private

      CHARS = {
        :passed    => '.',
        :failed    => 'F',
        :undefined => 'U',
        :pending   => 'P',
        :skipped   => 'S'
      }

      def progress(status)
        char = CHARS[status]
        @io.print(format_string(char, status))
      end
      
    end
  end
end