module Cucumber
  module Parser
    # TIP: When you hack on the grammar, just delete feature.rb in this directory.
    # Also make sure you have uninstalled all cucumber gems (don't forget xxx-cucumber
    # github gems).
    #
    # Treetop will then generate the parser in-memory. When you're happy, just generate
    # the rb file with tt feature.tt
    module Table
      include Treetop::Runtime

      def root
        @root || :table
      end

      module Table0
        def build
          Ast::Table.new(raw)
        end

        def raw
          elements.map{|e| e.build}
        end
      end

      def _nt_table
        start_index = index
        if node_cache[:table].has_key?(index)
          cached = node_cache[:table][index]
          @index = cached.interval.end if cached
          return cached
        end

        s0, i0 = [], index
        loop do
          r1 = _nt_table_row
          if r1
            s0 << r1
          else
            break
          end
        end
        if s0.empty?
          self.index = i0
          r0 = nil
        else
          r0 = SyntaxNode.new(input, i0...index, s0)
          r0.extend(Table0)
        end

        node_cache[:table][start_index] = r0

        return r0
      end

      module TableRow0
        def cell
          elements[0]
        end

      end

      module TableRow1
        def cells
          elements[2]
        end

      end

      module TableRow2
        def build
          row = cells.elements.map do |elt| 
            value = elt.cell.text_value.strip
            value.empty? ? nil : value
          end

          class << row
            attr_accessor :line
          end
          row.line = cells.line

          row
        end
      end

      def _nt_table_row
        start_index = index
        if node_cache[:table_row].has_key?(index)
          cached = node_cache[:table_row][index]
          @index = cached.interval.end if cached
          return cached
        end

        i0, s0 = index, []
        s1, i1 = [], index
        loop do
          r2 = _nt_space
          if r2
            s1 << r2
          else
            break
          end
        end
        r1 = SyntaxNode.new(input, i1...index, s1)
        s0 << r1
        if r1
          if input.index('|', index) == index
            r3 = (SyntaxNode).new(input, index...(index + 1))
            @index += 1
          else
            terminal_parse_failure('|')
            r3 = nil
          end
          s0 << r3
          if r3
            s4, i4 = [], index
            loop do
              i5, s5 = index, []
              r6 = _nt_cell
              s5 << r6
              if r6
                if input.index('|', index) == index
                  r7 = (SyntaxNode).new(input, index...(index + 1))
                  @index += 1
                else
                  terminal_parse_failure('|')
                  r7 = nil
                end
                s5 << r7
              end
              if s5.last
                r5 = (SyntaxNode).new(input, i5...index, s5)
                r5.extend(TableRow0)
              else
                self.index = i5
                r5 = nil
              end
              if r5
                s4 << r5
              else
                break
              end
            end
            if s4.empty?
              self.index = i4
              r4 = nil
            else
              r4 = SyntaxNode.new(input, i4...index, s4)
            end
            s0 << r4
            if r4
              s8, i8 = [], index
              loop do
                r9 = _nt_space
                if r9
                  s8 << r9
                else
                  break
                end
              end
              r8 = SyntaxNode.new(input, i8...index, s8)
              s0 << r8
              if r8
                i10 = index
                s11, i11 = [], index
                loop do
                  r12 = _nt_eol
                  if r12
                    s11 << r12
                  else
                    break
                  end
                end
                if s11.empty?
                  self.index = i11
                  r11 = nil
                else
                  r11 = SyntaxNode.new(input, i11...index, s11)
                end
                if r11
                  r10 = r11
                else
                  r13 = _nt_eof
                  if r13
                    r10 = r13
                  else
                    self.index = i10
                    r10 = nil
                  end
                end
                s0 << r10
              end
            end
          end
        end
        if s0.last
          r0 = (SyntaxNode).new(input, i0...index, s0)
          r0.extend(TableRow1)
          r0.extend(TableRow2)
        else
          self.index = i0
          r0 = nil
        end

        node_cache[:table_row][start_index] = r0

        return r0
      end

      module Cell0
      end

      def _nt_cell
        start_index = index
        if node_cache[:cell].has_key?(index)
          cached = node_cache[:cell][index]
          @index = cached.interval.end if cached
          return cached
        end

        s0, i0 = [], index
        loop do
          i1, s1 = index, []
          i2 = index
          i3 = index
          if input.index('|', index) == index
            r4 = (SyntaxNode).new(input, index...(index + 1))
            @index += 1
          else
            terminal_parse_failure('|')
            r4 = nil
          end
          if r4
            r3 = r4
          else
            r5 = _nt_eol
            if r5
              r3 = r5
            else
              self.index = i3
              r3 = nil
            end
          end
          if r3
            r2 = nil
          else
            self.index = i2
            r2 = SyntaxNode.new(input, index...index)
          end
          s1 << r2
          if r2
            if index < input_length
              r6 = (SyntaxNode).new(input, index...(index + 1))
              @index += 1
            else
              terminal_parse_failure("any character")
              r6 = nil
            end
            s1 << r6
          end
          if s1.last
            r1 = (SyntaxNode).new(input, i1...index, s1)
            r1.extend(Cell0)
          else
            self.index = i1
            r1 = nil
          end
          if r1
            s0 << r1
          else
            break
          end
        end
        r0 = SyntaxNode.new(input, i0...index, s0)

        node_cache[:cell][start_index] = r0

        return r0
      end

      def _nt_space
        start_index = index
        if node_cache[:space].has_key?(index)
          cached = node_cache[:space][index]
          @index = cached.interval.end if cached
          return cached
        end

        if input.index(Regexp.new('[ \\t]'), index) == index
          r0 = (SyntaxNode).new(input, index...(index + 1))
          @index += 1
        else
          r0 = nil
        end

        node_cache[:space][start_index] = r0

        return r0
      end

      module Eol0
      end

      def _nt_eol
        start_index = index
        if node_cache[:eol].has_key?(index)
          cached = node_cache[:eol][index]
          @index = cached.interval.end if cached
          return cached
        end

        i0 = index
        if input.index("\n", index) == index
          r1 = (SyntaxNode).new(input, index...(index + 1))
          @index += 1
        else
          terminal_parse_failure("\n")
          r1 = nil
        end
        if r1
          r0 = r1
        else
          i2, s2 = index, []
          if input.index("\r", index) == index
            r3 = (SyntaxNode).new(input, index...(index + 1))
            @index += 1
          else
            terminal_parse_failure("\r")
            r3 = nil
          end
          s2 << r3
          if r3
            if input.index("\n", index) == index
              r5 = (SyntaxNode).new(input, index...(index + 1))
              @index += 1
            else
              terminal_parse_failure("\n")
              r5 = nil
            end
            if r5
              r4 = r5
            else
              r4 = SyntaxNode.new(input, index...index)
            end
            s2 << r4
          end
          if s2.last
            r2 = (SyntaxNode).new(input, i2...index, s2)
            r2.extend(Eol0)
          else
            self.index = i2
            r2 = nil
          end
          if r2
            r0 = r2
          else
            self.index = i0
            r0 = nil
          end
        end

        node_cache[:eol][start_index] = r0

        return r0
      end

      def _nt_eof
        start_index = index
        if node_cache[:eof].has_key?(index)
          cached = node_cache[:eof][index]
          @index = cached.interval.end if cached
          return cached
        end

        i0 = index
        if index < input_length
          r1 = (SyntaxNode).new(input, index...(index + 1))
          @index += 1
        else
          terminal_parse_failure("any character")
          r1 = nil
        end
        if r1
          r0 = nil
        else
          self.index = i0
          r0 = SyntaxNode.new(input, index...index)
        end

        node_cache[:eof][start_index] = r0

        return r0
      end

    end

    class TableParser < Treetop::Runtime::CompiledParser
      include Table
    end

  end
end