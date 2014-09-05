module Cucumber
  module MultilineArgument
    class DataTable < SimpleDelegator

      NULL_CONVERSIONS = Hash.new({ :strict => false, :proc => lambda{ |cell_value| cell_value } }).freeze

      def initialize(data, conversion_procs = NULL_CONVERSIONS.dup, header_mappings = {}, header_conversion_proc = nil)
        case data
        when Core::Ast::DataTable
          super(data)
        when Array
          super(Core::Ast::DataTable.new(data, Core::Ast::Location.of_caller))
        end
        @conversion_procs = conversion_procs
        @header_mappings = header_mappings
        @header_conversion_proc = header_conversion_proc
      end

      def append_to(array)
        array << self
      end

      def to_json(options)
        raw.to_json(options)
      end

      def cells_rows #:nodoc:
        @rows ||= cell_matrix.map do |cell_row|
          Cells.new(self, cell_row)
        end
      end

      def columns #:nodoc:
        @columns ||= cell_matrix.transpose.map do |cell_row|
          Cells.new(self, cell_row)
        end
      end

      def column_names #:nodoc:
        @col_names ||= cell_matrix[0].map { |cell| cell.value }
      end

      def rows
        hashes.map do |hash|
          # TODO: Shouldn't we be using mapped headers not raw headers
          hash.values_at *headers
        end
      end

      def headers #:nodoc:
        raw.first
      end

      def cell_matrix
        @cell_matrix ||= raw.map do |raw_row|
          line = raw_row.line rescue -1
          raw_row.map do |raw_cell|
            Cell.new(raw_cell, self, line)
          end
        end
      end

      def transpose
        self.class.new(data.transpose, @conversion_procs, @header_mappings, @header_conversion_proc)
      end

      # Converts this table into an Array of Hash where the keys of each
      # Hash are the headers in the table. For example, a DataTable built from
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
      def hashes
        build_hashes
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
        self.transpose.hashes[0]
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
        # TODO: Remove this method for 2.0
        @conversion_procs[column_name.to_s] = { :strict => strict, :proc => conversion_proc }
        self
      end

      # Returns a new Table with an additional column mapping. See #map_column!
      def map_column(column_name, strict=true, &conversion_proc)
        conversion_procs = @conversion_procs.dup
        conversion_procs[column_name.to_s] = { :strict => strict, :proc => conversion_proc }
        self.class.new(raw.dup, conversion_procs, @header_mappings.dup, @header_conversion_proc)
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
      # You may also pass in a block if you wish to convert all of the headers:
      #
      #   table.map_headers! { |header| header.downcase }
      #   table.hashes.keys
      #   # => ['phone number', 'address']
      #
      # When a block is passed in along with a hash then the mappings in the hash take precendence:
      #
      #   table.map_headers!('Address' => 'ADDRESS') { |header| header.downcase }
      #   table.hashes.keys
      #   # => ['phone number', 'ADDRESS']
      #
      def map_headers!(mappings={}, &block)
        # TODO: Remove this method for 2.0
        clear_cache!
        @header_mappings = mappings
        @header_conversion_proc = block
      end
      # Returns a new Table where the headers are redefined. See #map_headers!
      def map_headers(mappings={}, &block)
        self.class.new raw.dup, @conversion_procs.dup, mappings, block
      end

      def diff!(other_table)
        other_table = ensure_table(other_table)
        other_table_cell_matrix = other_table.cell_matrix

        ensure_green!

        require_diff_lcs
        cell_matrix.extend(Diff::LCS)

        changes = cell_matrix.diff(other_table_cell_matrix).flatten

        return if changes.empty?

        inserted = 0
        missing  = 0

        changes.each do |change|
          if(change.action == '-')
            missing_row_pos = change.position + inserted
            cell_matrix[missing_row_pos].each{|cell| cell.status = :undefined}

            missing += 1
          else # '+'
            inserted_row = change.element
            inserted_row.each{|cell| cell.status = :comment}

            insert_row_pos = change.position + missing
            cell_matrix.insert(insert_row_pos, inserted_row)

            inserted += 1
          end
        end

        raise Different.new(self)
      end

      # Matches +pattern+ against the header row of the table.
      # This is used especially for argument transforms.
      #
      # Example:
      #  | column_1_name | column_2_name |
      #  | x             | y             |
      #
      #  table.match(/table:column_1_name,column_2_name/) #=> non-nil
      #
      # Note: must use 'table:' prefix on match
      def match(pattern)
        header_to_match = "table:#{headers.join(',')}"
        pattern.match(header_to_match)
      end

      def ensure_green! #:nodoc:
        each_cell{|cell| cell.status = :passed}
      end

      def to_hash(cells) #:nodoc:
        hash = Hash.new do |hash, key|
          hash[key.to_s] if key.is_a?(Symbol)
        end
        column_names.each_with_index do |column_name, column_index|
          hash[column_name] = cells.value(column_index)
        end
        hash
      end

      private
      def data
        __getobj__
      end

      def build_hashes
        convert_headers!
        convert_columns!
        cells_rows[1..-1].map do |row|
          row.to_hash
        end
      end

      def convert_columns! #:nodoc:
        @conversion_procs.each do |column_name, conversion_proc|
          verify_column(column_name) if conversion_proc[:strict]
        end

        cell_matrix.transpose.each do |col|
          column_name = col[0].value
          conversion_proc = @conversion_procs[column_name][:proc]
          col[1..-1].each do |cell|
            cell.value = conversion_proc.call(cell.value)
          end
        end
      end

      def convert_headers! #:nodoc:
        header_cells = cell_matrix[0]

        if @header_conversion_proc
          header_values = header_cells.map { |cell| cell.value } - @header_mappings.keys
          @header_mappings = @header_mappings.merge(Hash[*header_values.zip(header_values.map(&@header_conversion_proc)).flatten])
        end

        @header_mappings.each_pair do |pre, post|
          mapped_cells = header_cells.select { |cell| pre === cell.value }
          raise "No headers matched #{pre.inspect}" if mapped_cells.empty?
          raise "#{mapped_cells.length} headers matched #{pre.inspect}: #{mapped_cells.map { |c| c.value }.inspect}" if mapped_cells.length > 1
          mapped_cells[0].value = post
          if @conversion_procs.has_key?(pre)
            @conversion_procs[post] = @conversion_procs.delete(pre)
          end
        end
      end

      def verify_column(column_name) #:nodoc:
        raise %{The column named "#{column_name}" does not exist} unless raw[0].include?(column_name)
      end

      def verify_table_width(width) #:nodoc:
        raise %{The table must have exactly #{width} columns} unless raw[0].size == width
      end

      def ensure_table(table_or_array) #:nodoc:
        return table_or_array if DataTable === table_or_array
        DataTable.new(table_or_array)
      end

      def require_diff_lcs #:nodoc:
        begin
          require 'diff/lcs'
        rescue LoadError => e
          e.message << "\n Please gem install diff-lcs\n"
          raise e
        end
      end

      def clear_cache! #:nodoc:
        @hashes = @rows_hash = @col_names = @rows = @columns = nil
      end

      class Different < StandardError
        attr_reader :table
        def initialize(table)
          @table = table
          super("Tables were not identical")
        end
      end

      # Represents a row of cells or columns of cells
      class Cells #:nodoc:
        include Enumerable
        include Gherkin::Formatter::Escaping

        def initialize(table, cells)
          @table, @cells = table, cells
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

        private

        def index
          @table.index(self)
        end

        def width
          map{|cell| cell.value ? escape_cell(cell.value.to_s).unpack('U*').length : 0}.max
        end

        def each(&proc)
          @cells.each(&proc)
        end
      end

      class Cell #:nodoc:
        attr_reader :line, :table
        attr_accessor :status, :value

        def initialize(value, table, line)
          @value, @table, @line = value, table, line
        end

        def ==(o)
          value == o.value
        end

        def eql?(o)
          self == o
        end

        def hash
          [@value, @table, @line].hash
        end
      end
    end
  end
end
