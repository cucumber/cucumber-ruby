module Cucumber
  module Formatter
    # The formatter used for <tt>--format tag_cloud</tt>
    # Custom formatter that prints a tag cloud as a table.
    class TagCloud < Cucumber::Ast::Visitor
      def initialize(step_mother, io, options)
        super(step_mother)
        @io = io
        @options = options
        @counts = Hash.new{|h,k| h[k] = 0}
      end

      def visit_features(features)
        super
        print_summary(features)
      end

      def visit_tag_name(tag_name)
        @counts[tag_name] += 1
      end
  
      def print_summary(features)
        matrix = @counts.to_a.sort{|paira, pairb| paira[0] <=> pairb[0]}.transpose
        table = Cucumber::Ast::Table.new(matrix)
        Cucumber::Formatter::Pretty.new(@step_mother, @io, {}).visit_multiline_arg(table)
      end
    end
  end
end