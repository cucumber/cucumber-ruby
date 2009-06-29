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

      module Plus
        def kind
          :plus_cell
        end
      end

      module Minus
        def kind
          :minus_cell
        end
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
      # Surplus column detection will happen in the following conditions:
      #
      #   * +table+ is an Array of Hash
      #   * <tt>:coldiff => true</tt> is passed to +options+
      def diff!(table, options={})
        array_of_hashes = Array === table && Hash === table[0]
        table = hashes_to_array(table) if array_of_hashes
        table = table.raw if Table === table

        default_options = {:raise => true}
        default_options[:coldiff] = true if array_of_hashes
        options = default_options.merge(options)

        table, surplus_cols = *raw_and_surplus(table, options[:coldiff])
        empty_surplus_row = Array.new(surplus_cols.length, nil)

        require 'diff/lcs'
        @raw.extend(Diff::LCS)

        clear_cache!

        inserted = 0
        removed  = 0

        all_changes = @raw.diff(table)
        all_changes.each do |changes|
          changes.each do |change|
            if(change.action == '+')
              pos = change.position + removed
              raw_row = change.element.map do |raw_cell|
                raw_cell = raw_cell.dup.extend(Plus)
                raw_cell
              end
              @raw.insert(pos, raw_row)
              surplus_cols.insert(pos, empty_surplus_row) if surplus_cols.any?
              inserted += 1
            elsif(change.action == '-')
              pos = change.position + inserted
              missing_row = @raw[pos]
              change.element.length.times do |n|
                missing_row[n].extend(Minus)
              end
              removed += 1
            else
              raise "Unknown change: #{change.action}"
            end
          end
        end

        if surplus_cols.any?
          @raw = (@raw.transpose + surplus_cols).transpose
        end

        raise "Tables were not identical" if all_changes.any? && options[:raise]
      end

      def raw_and_surplus(raw, coldiff)
        return [raw, []] unless coldiff

        transposed_raw = raw.transpose
        headers = @raw[0]

        transposed_raw, surplus_columns = transposed_raw.partition do |col|
          headers.index(col[0])
        end
        
        transposed_raw.sort! do |col_a, col_b|
          headers.index(col_a[0]) <=> headers.index(col_b[0])
        end
        
        surplus_columns = surplus_columns.map do |surplus_column|
          surplus_column.map do |cell|
            cell.dup.extend(Plus)
          end
        end

        [transposed_raw.transpose, surplus_columns]
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
        @hashes = @rows_hash = @rows = @cell_matrix = nil
      end

      def col_width(col)
        columns[col].__send__(:width)
      end

      def columns
        @columns ||= cell_matrix.transpose.map do |cell_row|
          @cells_class.new(self, cell_row)
        end.freeze
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

      def new_cell(raw_cell, row, col, line)
        @cell_class.new(raw_cell, self, row, col, line)
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

        def kind
          @cells[0].kind
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
        attr_reader :value, :line
        attr_writer :status

        def initialize(value, table, row, col, line)
          @value, @table, @row, @col, @line = value, table, row, col, line
        end

        def accept(visitor)
          @status = :undefined if kind == :minus_cell
          @status = :comment   if kind == :plus_cell
          visitor.visit_table_cell_value(@value, col_width, @status)
        end

        def header_cell
          @table.header_cell(@col)
        end

        # For testing only
        def to_sexp #:nodoc:
          [kind, @value]
        end

        def kind
          @value.respond_to?(:kind) ? @value.kind : :cell
        end

        private

        def col_width
          @table.__send__(:col_width, @col)
        end
      end
    end
  end
end
