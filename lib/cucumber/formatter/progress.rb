require 'cucumber/formatter/console'

module Cucumber
  module Formatter
    class Progress < Ast::Visitor
      include Console

      def initialize(step_mother, io, options)
        super(step_mother)
        @io = (io == STDOUT) ? Kernel : io
        @options = options
        @errors             = []
        @pending_scenarios  = []
      end

      def visit_features(features)
        super
        print_summary(@io, features)
      end

      def visit_feature_element(feature_element)
        @io.print(pending("S")) if feature_element.pending?
        super
      end

      def visit_step_name(gwt, step_name, status, step_invocation, comment_padding)
        @io.print(format_string('.', status)) unless status == :outline
      end

      def visit_table_cell_value(value, width, status)
        @io.print(format_string('.', status)) unless status == :thead
      end
    end
  end
end