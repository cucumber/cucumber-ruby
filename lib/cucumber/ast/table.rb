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

      def initialize(raw, conversion_procs = NULL_CONVERSIONS.dup)
        @cells_class = Cells
        @cell_class = Cell

        # Verify that it's square
        transposed = raw.transpose
        create_cell_matrix(raw)
        @conversion_procs = conversion_procs
      end

      # Creates a copy of this table, inheriting the column mappings.
      def dup
        self.class.new(raw.dup, @conversion_procs.dup)
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
        self.class.new(raw.transpose, @conversion_procs.dup)
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
      # gets converted into the following:
      #
      #   [['a', 'b], ['c', 'd']]
      #
      def raw
        cell_matrix.map do |row|
          row.map do |cell|
            cell.value
          end
        end
      end

      # Same as #raw, but skips the first (header) row
      def rows
        raw[1..-1]
      end

      def each_cells_row(&proc)
        cells_rows.each(&proc)
      end

      def accept(visitor)
        return if $cucumber_interrupted
        cells_rows.each do |row|
          visitor.visit_table_row(row)
        end
        nil
      end

      # For testing only
      def to_sexp #:nodoc:
        [:table, *cells_rows.map{|row| row.to_sexp}]
      end

      # Redefines the table headers. This makes it possible to use
      # prettier and more flexible header names in the features.  The
      # keys of +mappings+ are Strings or regular expressions
      # (anything that responds to #=== will work) that may match
      # column headings in the table.  The values of +mappings+ are
      # desired names for the columns.
      #
      # Example:
      #
      #   | Phone Number | Address |
      #   | 123456       | xyz     |
      #   | 345678       | abc     |
      #
      # A StepDefinition receiving this table can then map the columns 
      # with both Regexp and String:
      #
      #   table.map_headers!(/phone( number)?/i => :phone, 'Address' => :address)
      #   table.hashes
      #   # => [{:phone => '123456', :address => 'xyz'}, {:phone => '345678', :address => 'abc'}]
      #
      def map_headers!(mappings)
        header_cells = cell_matrix[0]
        mappings.each_pair do |pre, post|
          header_cell = header_cells.detect{|cell| pre === cell.value}
          header_cell.value = post
          if @conversion_procs.has_key?(pre)
            @conversion_procs[post] = @conversion_procs.delete(pre)
          end
        end
      end

      # Returns a new Table where the headers are redefined. See #map_headers!
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

      # Compares +other_table+ to self. If +other_table+ contains columns
      # and/or rows that are not in self, new columns/rows are added at the
      # relevant positions, marking the cells in those rows/columns as
      # <tt>surplus</tt>. Likewise, if +other_table+ lacks columns and/or 
      # rows that are present in self, these are marked as <tt>missing</tt>.
      #
      # <tt>surplus</tt> and <tt>missing</tt> cells are recognised by formatters
      # and displayed so that it's easy to read the differences.
      #
      # Cells that are different, but <em>look</em> identical (for example the
      # boolean true and the string "true") are converted to their Object#inspect
      # representation and preceded with (i) - to make it easier to identify
      # where the difference actually is.
      #
      # Since all tables that are passed to StepDefinitions always have String
      # objects in their cells, you may want to use #map_column! before calling
      # #diff!. You can use #map_column! on either of the tables.
      #
      # An exception is raised if there are missing rows or columns, or
      # surplus rows. An error is <em>not</em> raised for surplus columns.
      # Whether to raise or not raise can be changed by setting values in
      # +options+ to true or false:
      #
      #   * <tt>missing_row</tt>: Raise on missing rows (defaults to true)
      #   * <tt>surplus_row</tt>: Raise on surplus rows (defaults to true)
      #   * <tt>missing_col</tt>: Raise on missing columns (defaults to true)
      #   * <tt>surplus_col</tt>: Raise on surplus columns (defaults to false)
      #
      # The +other_table+ argument can be another Table, an Array of Array or
      # an Array of Hash (similar to the structure returned by #hashes).
      #
      # Calling this method is particularly useful in <tt>Then</tt> steps that take
      # a Table argument, if you want to compare that table to some actual values. 
      #
      def diff!(other_table, options={})
        options = {:missing_row => true, :surplus_row => true, :missing_col => true, :surplus_col => false}.merge(options)

        other_table = ensure_table(other_table)
        other_table.convert_columns!
        ensure_green!

        original_width = cell_matrix[0].length
        other_table_cell_matrix = pad!(other_table.cell_matrix)
        padded_width = cell_matrix[0].length

        missing_col = cell_matrix[0].detect{|cell| cell.status == :undefined}
        surplus_col = padded_width > original_width

        require_diff_lcs
        cell_matrix.extend(Diff::LCS)
        convert_columns!
        changes = cell_matrix.diff(other_table_cell_matrix).flatten

        inserted = 0
        missing  = 0

        row_indices = Array.new(other_table_cell_matrix.length) {|n| n}

        last_change = nil
        missing_row_pos = nil
        insert_row_pos  = nil
        
        changes.each do |change|
          if(change.action == '-')
            missing_row_pos = change.position + inserted
            cell_matrix[missing_row_pos].each{|cell| cell.status = :undefined}
            row_indices.insert(missing_row_pos, nil)
            missing += 1
          else # '+'
            insert_row_pos = change.position + missing
            inserted_row = change.element
            inserted_row.each{|cell| cell.status = :comment}
            cell_matrix.insert(insert_row_pos, inserted_row)
            row_indices[insert_row_pos] = nil
            inspect_rows(cell_matrix[missing_row_pos], inserted_row) if last_change && last_change.action == '-'
            inserted += 1
          end
          last_change = change
        end

        other_table_cell_matrix.each_with_index do |other_row, i|
          row_index = row_indices.index(i)
          row = cell_matrix[row_index] if row_index
          if row
            (original_width..padded_width).each do |col_index|
              surplus_cell = other_row[col_index]
              row[col_index].value = surplus_cell.value if row[col_index]
            end
          end
        end
        
        clear_cache!
        should_raise = 
          missing_row_pos && options[:missing_row] ||
          insert_row_pos  && options[:surplus_row] ||
          missing_col     && options[:missing_col] ||
          surplus_col     && options[:surplus_col]
        raise 'Tables were not identical' if should_raise
      end

      def to_hash(cells) #:nodoc:
        hash = Hash.new do |hash, key|
          hash[key.to_s] if key.is_a?(Symbol)
        end
        raw[0].each_with_index do |column_name, column_index|
          value = @conversion_procs[column_name].call(cells.value(column_index))
          hash[column_name] = value
        end
        hash
      end

      def index(cells) #:nodoc:
        cells_rows.index(cells)
      end

      def verify_column(column_name)
        raise %{The column named "#{column_name}" does not exist} unless raw[0].include?(column_name)
      end
      
      def verify_table_width(width)
        raise %{The table must have exactly #{width} columns} unless raw[0].size == width
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
        raw.first
      end

      def header_cell(col)
        cells_rows[0][col]
      end

      def cell_matrix
        @cell_matrix
      end

      def col_width(col)
        columns[col].__send__(:width)
      end

      def to_s(options = {})
        options = {:color => true, :indent => 2, :prefixes => TO_S_PREFIXES}.merge(options)
        io = StringIO.new

        c = Term::ANSIColor.coloring?
        Term::ANSIColor.coloring = options[:color]
        f = Formatter::Pretty.new(nil, io, options)
        f.instance_variable_set('@indent', options[:indent])
        f.visit_multiline_arg(self)
        Term::ANSIColor.coloring = c

        io.rewind
        s = "\n" + io.read + (" " * (options[:indent] - 2))
        s
      end

      private

      TO_S_PREFIXES = Hash.new('    ')
      TO_S_PREFIXES[:comment]   = ['(+) ']
      TO_S_PREFIXES[:undefined] = ['(-) ']

      protected

      def inspect_rows(missing_row, inserted_row)
        missing_row.each_with_index do |missing_cell, col|
          inserted_cell = inserted_row[col]
          if(missing_cell.value != inserted_cell.value && (missing_cell.value.to_s == inserted_cell.value.to_s))
            missing_cell.inspect!
            inserted_cell.inspect!
          end
        end
      end

      def create_cell_matrix(raw)
        @cell_matrix = raw.map do |raw_row|
          line = raw_row.line rescue -1
          raw_row.map do |raw_cell|
            new_cell(raw_cell, line)
          end
        end
      end

      def convert_columns!
        cell_matrix.transpose.each do |col|
          conversion_proc = @conversion_procs[col[0].value]
          col[1..-1].each do |cell|
            cell.value = conversion_proc.call(cell.value)
          end
        end
      end

      def require_diff_lcs
        begin
          require 'diff/lcs'
        rescue LoadError => e
          e.message << "\n Please gem install diff-lcs\n"
          raise e
        end
      end

      def clear_cache!
        @hashes = @rows_hash = @rows = @columns = nil
      end

      def columns
        @columns ||= cell_matrix.transpose.map do |cell_row|
          @cells_class.new(self, cell_row)
        end.freeze
      end

      def new_cell(raw_cell, line)
        @cell_class.new(raw_cell, self, line)
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
              SurplusCell.new(val, self, -1)
            end
          end
          mapped_cols.insert(col_index, other_padded_col)
        end

        unmapped_cols.each_with_index do |col, col_index|
          empty_col = (0...cell_matrix.length).map do |row| 
            SurplusCell.new(nil, self, -1)
          end
          cols << empty_col
        end

        @cell_matrix = cols.transpose
        (mapped_cols + unmapped_cols).transpose
      end

      def ensure_table(table_or_array)
        return table_or_array if Table === table_or_array
        table_or_array = hashes_to_array(table_or_array) if Hash === table_or_array[0]
        table_or_array = enumerable_to_array(table_or_array) unless Array == table_or_array[0]
        Table.new(table_or_array)
      end

      def hashes_to_array(hashes)
        header = hashes[0].keys
        [header] + hashes.map{|hash| header.map{|key| hash[key]}}
      end

      def enumerable_to_array(rows)
        rows.map{|row| row.map{|cell| cell}}
      end

      def ensure_green!
        each_cell{|cell| cell.status = :passed}
      end

      def each_cell(&proc)
        cell_matrix.each{|row| row.each(&proc)}
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
          return if $cucumber_interrupted
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
        attr_reader :line, :table
        attr_accessor :status, :value

        def initialize(value, table, line)
          @value, @table, @line = value, table, line
        end

        def accept(visitor)
          return if $cucumber_interrupted
          visitor.visit_table_cell_value(value, status)
        end

        def inspect!
          @value = "(i) #{value.inspect}"
        end

        def ==(o)
          SurplusCell === o || value == o.value
        end

        # For testing only
        def to_sexp #:nodoc:
          [:cell, @value]
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
