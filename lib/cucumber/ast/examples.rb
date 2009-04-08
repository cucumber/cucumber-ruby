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

      def skip_invoke!
        @outline_table.skip_invoke!
      end

      def each_example_row(&proc)
        @outline_table.cells_rows[1..-1].each(&proc)
      end

      def to_sexp
        [:examples, @keyword, @name, @outline_table.to_sexp]
      end
    end
  end
end
