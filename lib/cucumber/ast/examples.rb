module Cucumber
  module Ast
    class Examples
      def initialize(keyword, name, outline_table)
        @keyword, @name, @outline_table = keyword, name, outline_table
      end

      def accept(visitor)
        visitor.visit_examples_name(@keyword, @name)
        @outline_table.accept(visitor, nil)
      end

      def to_sexp
        [:examples, @keyword, @name, @outline_table.to_sexp]
      end
    end
  end
end
