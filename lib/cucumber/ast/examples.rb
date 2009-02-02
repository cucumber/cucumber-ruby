module Cucumber
  module Ast
    class Examples
      def initialize(line, keyword, name, outline_table)
        @keyword, @name, @outline_table = keyword, name, outline_table
      end

      def accept(visitor)
        visitor.visit_examples_name(@keyword, @name)
        visitor.visit_outline_table(@outline_table)
      end

      def each_example_row(&proc)
        @outline_table.each_cells_row(&proc)
      end

      def at_lines?(lines)
        lines.empty? || lines.index(@line) || @outline_table.at_lines?(lines)
      end

      def to_sexp
        [:examples, @keyword, @name, @outline_table.to_sexp]
      end
    end
  end
end
