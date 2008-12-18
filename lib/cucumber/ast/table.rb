module Cucumber
  module Ast
    # Holds the data of a table parsed from a feature file:
    #
    #   |a|b|
    #   |c|d|
    #
    # This gets parsed into a Table holding the values <tt>[['a', 'b'], ['c', 'd']]</tt>
    #
    class Table
      attr_accessor :file

      def initialize(raw)
        # Verify that it's square
        raw.transpose
        @raw = raw
      end

      def accept(visitor)
        each do |row|
          visitor.visit_table_row(row)
        end
      end

      private

      def col_width(col)
        columns[col].__send__(:width)
      end

      def each(&proc)
        rows.each(&proc)
      end

      def rows
        @rows ||= cell_matrix.map do |cell_row|
          Cells.new(cell_row)
        end
      end

      def columns
        @columns ||= cell_matrix.transpose.map do |cell_row|
          Cells.new(cell_row)
        end
      end

      def cell_matrix
        row = -1
        @cell_matrix ||= @raw.map do |raw_row|
          row += 1
          col = -1
          raw_row.map do |raw_cell|
            col += 1
            Cell.new(raw_cell, self, row, col)
          end
        end
      end

      # Represents a row of cells or columns of cells
      class Cells
        include Enumerable

        def initialize(cells)
          @cells = cells
        end

        def accept(visitor)
          each do |cell|
            visitor.visit_table_cell(cell)
          end
        end

        private

        def width
          map{|cell| cell.value.length}.max
        end

        def [](n)
          @cells[n]
        end

        def each(&proc)
          @cells.each(&proc)
        end
      end

      class Cell
        attr_reader :value

        def initialize(value, table, row, col)
          @value, @table, @row, @col = value, table, row, col
        end

        def accept(visitor)
          visitor.visit_table_cell_value(@value, col_width)
        end

        private

        def col_width
          @col_width ||= @table.__send__(:col_width, @col)
        end
      end
    end
  end
end
