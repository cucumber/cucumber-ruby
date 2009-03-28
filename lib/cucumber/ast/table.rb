module Cucumber
  module Ast
    # Holds the data of a table parsed from a feature file:
    #
    #   | a | b |
    #   | c | d |
    #
    # This gets parsed into a Table holding the values <tt>[['a', 'b'], ['c', 'd']]</tt>
    #
    class Table      
      NULL_CONVERSIONS = Hash.new(lambda{ |cell_value| cell_value }).freeze

      attr_accessor :file

      def initialize(raw, conversions = NULL_CONVERSIONS.dup)
        # Verify that it's square
        raw.transpose
        @raw = raw
        @cells_class = Cells
        @cell_class = Cell
        @conversion_procs = conversions
      end

      # Creates a copy of this table, inheriting the column mappings.
      def dup
        self.class.new(@raw.dup, @conversion_procs.dup)
      end

      # Returns a new, transposed table. Example:
      #
      # | a | 7 | 4 |
      # | b | 9 | 2 |
      #
      # Gets converted into the following:
      #
      # | a | b |
      # | 7 | 9 |
      # | 4 | 2 |
      #
      def transpose
        self.class.new(@raw.transpose, @conversion_procs.dup)
      end

      # Converts this table into an Array of Hash where the keys of each
      # Hash are the headers in the table. For example, a Table built from
      # the following plain text:
      #
      #   | a | b | sum |
      #   | 2 | 3 | 5   |
      #   | 7 | 9 | 16  |
      #
      # Gets converted into the following:
      #
      #   [{'a' => '2', 'b' => '3', 'sum' => '5'}, {'a' => '7', 'b' => '9', 'sum' => '16'}]
      #
      # Use #map_column! to specify how values in a column are converted.
      #
      def hashes
        @hashes ||= cells_rows[1..-1].map do |row|
          row.to_hash
        end
      end
      
      # Converts this table into a Hash where the first column is
      # used as keys and the second column is used as values
      #
      #   | a | 2 |
      #   | b | 3 |
      #
      # Gets converted into the following:
      #
      #   {'a' => '2', 'b' => '3'}
      #
      # The table must be exactly two columns wide 
      #
      def rows_hash
        verify_table_width(2)
        @rows_hash = self.transpose.hashes[0]
      end

      # Gets the raw data of this table. For example, a Table built from
      # the following plain text:
      #
      #   | a | b |
      #   | c | d |
      #
      # Get converted into the following:
      #
      #   [['a', 'b], ['c', 'd']]
      #
      def raw
        @raw
      end

      # Same as #raw, but skips the first (header) row
      def rows
        @raw[1..-1]
      end

      def each_cells_row(&proc)
        cells_rows.each(&proc)
      end

      def matches_lines?(lines)
        cells_rows.detect{|row| row.matches_lines?(lines)}
      end

      def accept(visitor)
        cells_rows.each do |row|
          visitor.visit_table_row(row)
        end
        nil
      end

      def status=(status)
        cells_rows.each do |row|
          row.status = status
        end
      end

      # For testing only
      def to_sexp #:nodoc:
        [:table, *cells_rows.map{|row| row.to_sexp}]
      end

      # Returns a new Table where the headers are redefined. This makes it
      # possible to use prettier header names in the features. Example:
      #
      #   | Phone Number | Address |
      #   | 123456       | xyz     |
      #   | 345678       | abc     |
      #
      # A StepDefinition receiving this table can then map the columns:
      #
      #   mapped_table = table.map_columns('Phone Number' => :phone, 'Address' => :address)
      #   hashes = mapped_table.hashes
      #   # => [{:phone => '123456', :address => 'xyz'}, {:phone => '345678', :address => 'abc'}]
      #
      def map_headers(mappings)
        table = self.dup
        table.map_headers!(mappings)
        table
      end

      # Change how #hashes converts column values. The +column_name+ argument identifies the column
      # and +conversion_proc+ performs the conversion for each cell in that column. If +strict+ is 
      # true, an error will be raised if the column named +column_name+ is not found. If +strict+ 
      # is false, no error will be raised. Example:
      #
      #   Given /^an expense report for (.*) with the following posts:$/ do |table|
      #     posts_table.map_column!('amount') { |a| a.to_i }
      #     posts_table.hashes.each do |post|
      #       # post['amount'] is a Fixnum, rather than a String
      #     end
      #   end
      #
      def map_column!(column_name, strict=true, &conversion_proc)
        verify_column(column_name) if strict
        @conversion_procs[column_name] = conversion_proc
      end

      def to_hash(cells) #:nodoc:
        hash = Hash.new do |hash, key|
          hash[key.to_s] if key.is_a?(Symbol)
        end
        @raw[0].each_with_index do |column_name, column_index|
          value = @conversion_procs[column_name].call(cells.value(column_index))
          hash[column_name] = value
        end
        hash
      end

      def index(cells) #:nodoc:
        cells_rows.index(cells)
      end

      def verify_column(column_name)
        raise %{The column named "#{column_name}" does not exist} unless @raw[0].include?(column_name)
      end
      
      def verify_table_width(width)
        raise %{The table must have exactly #{width} columns} unless @raw[0].size == width
      end

      def arguments_replaced(arguments) #:nodoc:
        raw_with_replaced_args = raw.map do |row|
          row.map do |cell|
            cell_with_replaced_args = cell
            arguments.each do |name, value|
              if cell_with_replaced_args && cell_with_replaced_args.include?(name)
                cell_with_replaced_args = value ? cell_with_replaced_args.gsub(name, value) : nil
              end
            end
            cell_with_replaced_args
          end
        end
        Table.new(raw_with_replaced_args)
      end

      def cells_rows
        @rows ||= cell_matrix.map do |cell_row|
          @cells_class.new(self, cell_row)
        end
      end

      def header_cell(col)
        cells_rows[0][col]
      end

      protected

      def map_headers!(mappings)
        headers = @raw[0]
        mappings.each_pair do |pre, post|
          headers[headers.index(pre)] = post
          if @conversion_procs.has_key?(pre)
            @conversion_procs[post] = @conversion_procs.delete(pre)
          end
        end
      end

      private

      def col_width(col)
        columns[col].__send__(:width)
      end

      def columns
        @columns ||= cell_matrix.transpose.map do |cell_row|
          @cells_class.new(self, cell_row)
        end
      end

      def cell_matrix
        row = -1
        @cell_matrix ||= @raw.map do |raw_row|
          line = raw_row.line rescue -1
          row += 1
          col = -1
          raw_row.map do |raw_cell|
            col += 1
            @cell_class.new(raw_cell, self, row, col, line)
          end
        end
      end

      # Represents a row of cells or columns of cells
      class Cells
        include Enumerable
        attr_reader :exception

        def initialize(table, cells)
          @table, @cells = table, cells
        end

        def matches_lines?(lines)
          lines.index(line)
        end

        def accept(visitor)
          each do |cell|
            visitor.visit_table_cell(cell)
          end
          nil
        end

        # For testing only
        def to_sexp #:nodoc:
          [:row, *@cells.map{|cell| cell.to_sexp}]
        end

        def to_hash #:nodoc:
          @to_hash ||= @table.to_hash(self)
        end

        def value(n) #:nodoc:
          self[n].value
        end

        def [](n)
          @cells[n]
        end

        def line
          @cells[0].line
        end

        def dom_id
          "row_#{line}"
        end

        def status=(status)
          each do |cell|
            cell.status = status
          end
        end

        private

        def index
          @table.index(self)
        end

        def width
          map{|cell| cell.value ? cell.value.to_s.jlength : 0}.max
        end

        def each(&proc)
          @cells.each(&proc)
        end
      end

      class Cell
        attr_reader :value, :line
        attr_writer :status

        def initialize(value, table, row, col, line)
          @value, @table, @row, @col, @line = value, table, row, col, line
          @status = :passed
        end

        def accept(visitor)
          visitor.visit_table_cell_value(@value, col_width, @status)
        end

        def header_cell
          @table.header_cell(@col)
        end

        # For testing only
        def to_sexp #:nodoc:
          [:cell, @value]
        end

        private

        def col_width
          @col_width ||= @table.__send__(:col_width, @col)
        end
      end
    end
  end
end
