module Cucumber
  module Ast
    class Examples
      def initialize(name, outline_table)
        @name, @outline_table = name, outline_table
      end

      def accept(visitor)
        visitor.visit_examples_name(@name)
        @outline_table.accept(visitor, nil)
      end
    end
  end
end
