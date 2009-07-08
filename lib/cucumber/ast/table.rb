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
      include Enumerable
      
      NULL_CONVERSIONS = Hash.new(lambda{ |cell_value| cell_value }).freeze

      attr_accessor :file

      def self.default_arg_name
        "table"
      end

      def initialize(raw, conversions = NULL_CONVERSIONS.dup)
        # Verify that it's square
        transposed = raw.transpose
        @raw = raw
        @cells_class = Cells
        @cell_class = Cell
        @conversion_procs = conversions
      end

      def hashes_to_array(hashes)
        header = hashes[0].keys
        [header] + hashes.map{|hash| header.map{|key| hash[key]}}
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
        end.freeze
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
        return @rows_hash if @rows_hash
        verify_table_width(2)
        @rows_hash = self.transpose.hashes[0].freeze
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

      def accept(visitor)
        cells_rows.each do |row|
          visitor.visit_table_row(row)
        end
        nil
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

      # Compares +table+ to self and stores the diff internally in new rows.
      # If +table+ has different content than self, an exception is raised
      # (unless you pass :raise => false in +options+).
      #
      # The +table+ argument can be another Table, an Array of Array or
      # an Array of Hash (similar to the structure returned by #hashes).
      #
      # Calling this method is particularly useful in Then steps that take
      # a Table argument. Simply calling <tt>#diff!(actual_table)</tt> will 
      # cause your step to fail if the contents are different, and also
      # display the differences in the output.
      #
      # This method will attempt to identify surplus rows in certain situations.
      # Such columns will be added to the end (right) of the original table (self).
      # Surplus column detection will happen if one of the following conditions are true:
      #
      #   * +table+ is an Array of Hash
      #   * +table+ has a different number of columns than self
      #   * <tt>:coldiff => true</tt> is passed to +options+
      def diff!(other_table)
        other_table_cell_matrix = pad!(other_table.cell_matrix)

puts self.to_s
ot = Table.new([])
ot.instance_variable_set('@cell_matrix', other_table_cell_matrix)
puts ot.to_s

        require 'diff/lcs'
        cell_matrix.extend(Diff::LCS)
        changes = cell_matrix.diff(other_table_cell_matrix).flatten

        inserted = 0
        removed  = 0

        changes.each do |change|
          if(change.action == '+')
            pos = change.position + removed
            new_row = change.element
            new_row.each{|cell| cell.status = :comment} # TODO: cell.col is wrong (only bad for indent)
            cell_matrix.insert(pos, new_row)
            inserted += 1
          else # '-'
            pos = change.position + inserted
            cell_matrix[pos].each{|cell| cell.status = :undefined}
            removed += 1
          end
        end
        clear_cache!
puts self.to_s
      end

      TO_S_PREFIXES = Hash.new('    ')
      TO_S_PREFIXES[:comment]   = ['(+) ']
      TO_S_PREFIXES[:undefined] = ['(-) ']

      def to_s(options = {})
        options = {:color => true, :indent => 2, :prefixes => TO_S_PREFIXES}.merge(options)
        io = StringIO.new

        c = Term::ANSIColor.coloring?
        Term::ANSIColor.coloring = options[:color]
        f = Formatter::Pretty.new(nil, io, options)
        f.instance_variable_set('@indent', options[:indent])
        self.accept(f)
        Term::ANSIColor.coloring = c

        io.rewind
        s = "\n" + io.read + (" " * (options[:indent] - 2))
        s
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

      def has_text?(text)
        raw.flatten.compact.detect{|cell_value| cell_value.index(text)}
      end

      def cells_rows
        @rows ||= cell_matrix.map do |cell_row|
          @cells_class.new(self, cell_row)
        end
      end

      def headers
        @raw.first
      end

      def header_cell(col)
        cells_rows[0][col]
      end

      def cell_matrix
        row = -1
        @cell_matrix ||= @raw.map do |raw_row|
          line = raw_row.line rescue -1
          row += 1
          col = -1
          raw_row.map do |raw_cell|
            col += 1
            new_cell(raw_cell, row, col, line)
          end
        end.freeze
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

      def clear_cache!
        @hashes = @rows_hash = @rows = @columns = nil
      end

      def col_width(col)
        columns[col].__send__(:width)
      end

      def columns
        @columns ||= cell_matrix.transpose.map do |cell_row|
          @cells_class.new(self, cell_row)
        end.freeze
      end

      def new_cell(raw_cell, row, col, line)
        @cell_class.new(raw_cell, self, row, col, line)
      end

      # Pads our own cell_matrix and returns a cell matrix of same
      # column width that can be used for diffing
      def pad!(other_cell_matrix)
        clear_cache!
        cols = cell_matrix.transpose
        unmapped_cols = other_cell_matrix.transpose

        mapped_cols = []

        cols.each_with_index do |col, col_index|
          header = col[0]
          candidate_cols, unmapped_cols = unmapped_cols.partition do |other_col|
            other_col[0] == header
          end
          raise "More than one column has the header #{header}" if candidate_cols.size > 2

          other_padded_col = if candidate_cols.size == 1
            # Found a matching column
            candidate_cols[0]
          else
            mark_as_missing(cols[col_index])
            (0...other_cell_matrix.length).map do |row|
              val = row == 0 ? header.value : nil
              SurplusCell.new(val, self, row, col_index, -1)
            end
          end
          mapped_cols.insert(col_index, other_padded_col)
        end

        offset = cols.length
        unmapped_cols.each_with_index do |col, col_index|
          header = col[0]
          empty_col = (0...cell_matrix.length).map do |row| 
            val = row == 0 ? header.value : nil
            SurplusCell.new(val, self, row, col_index + offset, -1)
          end
          cols << empty_col
        end

        @cell_matrix = cols.transpose
        (mapped_cols + unmapped_cols).transpose
      end

      def r(cm)
        cm.map do |cr|
          cr.map do |c|
            "#{c.value} (#{c.status})"
          end
        end
      end

      def mark_as_missing(col)
        col.each do |cell|
          cell.status = :undefined
        end
      end

      # Represents a row of cells or columns of cells
      class Cells
        include Enumerable
        attr_reader :exception

        def initialize(table, cells)
          @table, @cells = table, cells
        end

        def accept(visitor)
          each do |cell|
            visitor.visit_table_cell(cell)
          end
          nil
        end

        # For testing only
        def to_sexp #:nodoc:
          [:row, line, *@cells.map{|cell| cell.to_sexp}]
        end

        def to_hash #:nodoc:
          @to_hash ||= @table.to_hash(self).freeze
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
        attr_reader :line, :col
        attr_accessor :status

        def initialize(value, table, row, col, line)
          @value, @table, @row, @col, @line = value, table, row, col, line
        end

        def value
          @value
        end

        def accept(visitor)
          visitor.visit_table_cell_value(value, col_width, status)
        end

        def header_cell
          @table.header_cell(@col)
        end

        def ==(o)
          SurplusCell === o || value == o.value
        end

        # For testing only
        def to_sexp #:nodoc:
          [:cell, @value]
        end

        private

        def col_width
          @table.__send__(:col_width, @col)
        end
      end
      
      class SurplusCell < Cell
        def status
          :comment
        end

        def ==(o)
          true
        end
      end
    end
  end
end
