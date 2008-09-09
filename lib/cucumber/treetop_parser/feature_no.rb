module Cucumber
module TreetopParser

module Feature
  include Treetop::Runtime

  def root
    @root || :root
  end

  module Root0
    def header
      elements[0]
    end

    def scenarios
      elements[2]
    end
  end

  module Root1
    
    def feature
      f = Tree::Feature.new(header.text_value.strip)
      scenarios.populate(f)
      f
    end
  end

  def _nt_root
    start_index = index
    if node_cache[:root].has_key?(index)
      cached = node_cache[:root][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_header
    s0 << r1
    if r1
      s2, i2 = [], index
      loop do
        r3 = _nt_whitespace
        if r3
          s2 << r3
        else
          break
        end
      end
      r2 = SyntaxNode.new(input, i2...index, s2)
      s0 << r2
      if r2
        r4 = _nt_scenarios
        s0 << r4
      end
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(Root0)
      r0.extend(Root1)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:root][start_index] = r0

    return r0
  end

  module Header0
  end

  def _nt_header
    start_index = index
    if node_cache[:header].has_key?(index)
      cached = node_cache[:header][index]
      @index = cached.interval.end if cached
      return cached
    end

    s0, i0 = [], index
    loop do
      i1, s1 = index, []
      i2 = index
      r3 = _nt_step_scenario
      if r3
        r2 = nil
      else
        self.index = i2
        r2 = SyntaxNode.new(input, index...index)
      end
      s1 << r2
      if r2
        if index < input_length
          r4 = (SyntaxNode).new(input, index...(index + 1))
          @index += 1
        else
          terminal_parse_failure("any character")
          r4 = nil
        end
        s1 << r4
      end
      if s1.last
        r1 = (SyntaxNode).new(input, i1...index, s1)
        r1.extend(Header0)
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

    node_cache[:header][start_index] = r0

    return r0
  end

  module Scenarios0
    def step_scenario
      elements[0]
    end

    def more
      elements[1]
    end
  end

  module Scenarios1
    def populate(feature)
      step_scenario.populate(feature)
      more.elements.each { |m| m.populate(feature) }
    end
  end

  def _nt_scenarios
    start_index = index
    if node_cache[:scenarios].has_key?(index)
      cached = node_cache[:scenarios][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_step_scenario
    s0 << r1
    if r1
      s2, i2 = [], index
      loop do
        i3 = index
        r4 = _nt_table
        if r4
          r3 = r4
        else
          r5 = _nt_step_scenario
          if r5
            r3 = r5
          else
            self.index = i3
            r3 = nil
          end
        end
        if r3
          s2 << r3
        else
          break
        end
      end
      r2 = SyntaxNode.new(input, i2...index, s2)
      s0 << r2
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(Scenarios0)
      r0.extend(Scenarios1)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:scenarios][start_index] = r0

    return r0
  end

  module StepScenario0
  end

  module StepScenario1
    def scenario_keyword
      elements[0]
    end

    def name
      elements[3]
    end

    def blanks
      elements[5]
    end

    def steps
      elements[6]
    end
  end

  module StepScenario2
    def populate(feature)
      sc = feature.add_scenario(name.text_value.strip)
      steps.elements.each{|s| s.populate(sc)}
      Feature.last_scenario = sc
    end
  end

  def _nt_step_scenario
    start_index = index
    if node_cache[:step_scenario].has_key?(index)
      cached = node_cache[:step_scenario][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_scenario_keyword
    s0 << r1
    if r1
      if input.index(":", index) == index
        r2 = (SyntaxNode).new(input, index...(index + 1))
        @index += 1
      else
        terminal_parse_failure(":")
        r2 = nil
      end
      s0 << r2
      if r2
        s3, i3 = [], index
        loop do
          r4 = _nt_whitespace
          if r4
            s3 << r4
          else
            break
          end
        end
        if s3.empty?
          self.index = i3
          r3 = nil
        else
          r3 = SyntaxNode.new(input, i3...index, s3)
        end
        s0 << r3
        if r3
          s5, i5 = [], index
          loop do
            i6, s6 = index, []
            i7 = index
            r8 = _nt_newline
            if r8
              r7 = nil
            else
              self.index = i7
              r7 = SyntaxNode.new(input, index...index)
            end
            s6 << r7
            if r7
              if index < input_length
                r9 = (SyntaxNode).new(input, index...(index + 1))
                @index += 1
              else
                terminal_parse_failure("any character")
                r9 = nil
              end
              s6 << r9
            end
            if s6.last
              r6 = (SyntaxNode).new(input, i6...index, s6)
              r6.extend(StepScenario0)
            else
              self.index = i6
              r6 = nil
            end
            if r6
              s5 << r6
            else
              break
            end
          end
          if s5.empty?
            self.index = i5
            r5 = nil
          else
            r5 = SyntaxNode.new(input, i5...index, s5)
          end
          s0 << r5
          if r5
            s10, i10 = [], index
            loop do
              r11 = _nt_newline
              if r11
                s10 << r11
              else
                break
              end
            end
            r10 = SyntaxNode.new(input, i10...index, s10)
            s0 << r10
            if r10
              r12 = _nt_blanks
              s0 << r12
              if r12
                s13, i13 = [], index
                loop do
                  r14 = _nt_step_or_given_scenario
                  if r14
                    s13 << r14
                  else
                    break
                  end
                end
                if s13.empty?
                  self.index = i13
                  r13 = nil
                else
                  r13 = SyntaxNode.new(input, i13...index, s13)
                end
                s0 << r13
              end
            end
          end
        end
      end
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(StepScenario1)
      r0.extend(StepScenario2)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:step_scenario][start_index] = r0

    return r0
  end

  def _nt_step_or_given_scenario
    start_index = index
    if node_cache[:step_or_given_scenario].has_key?(index)
      cached = node_cache[:step_or_given_scenario][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0 = index
    r1 = _nt_step
    if r1
      r0 = r1
    else
      r2 = _nt_given_scenario
      if r2
        r0 = r2
      else
        self.index = i0
        r0 = nil
      end
    end

    node_cache[:step_or_given_scenario][start_index] = r0

    return r0
  end

  module Step0
  end

  module Step1
    def step_keyword
      elements[1]
    end

    def name
      elements[3]
    end

    def blanks
      elements[5]
    end
  end

  module Step2
    def populate(scenario)
      line = input.line_of(interval.first)
      scenario.add_step(step_keyword.text_value, name.text_value.strip, line)
    end
  end

  def _nt_step
    start_index = index
    if node_cache[:step].has_key?(index)
      cached = node_cache[:step][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    s1, i1 = [], index
    loop do
      r2 = _nt_whitespace
      if r2
        s1 << r2
      else
        break
      end
    end
    r1 = SyntaxNode.new(input, i1...index, s1)
    s0 << r1
    if r1
      r3 = _nt_step_keyword
      s0 << r3
      if r3
        s4, i4 = [], index
        loop do
          r5 = _nt_whitespace
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
          s6, i6 = [], index
          loop do
            i7, s7 = index, []
            i8 = index
            r9 = _nt_newline
            if r9
              r8 = nil
            else
              self.index = i8
              r8 = SyntaxNode.new(input, index...index)
            end
            s7 << r8
            if r8
              if index < input_length
                r10 = (SyntaxNode).new(input, index...(index + 1))
                @index += 1
              else
                terminal_parse_failure("any character")
                r10 = nil
              end
              s7 << r10
            end
            if s7.last
              r7 = (SyntaxNode).new(input, i7...index, s7)
              r7.extend(Step0)
            else
              self.index = i7
              r7 = nil
            end
            if r7
              s6 << r7
            else
              break
            end
          end
          if s6.empty?
            self.index = i6
            r6 = nil
          else
            r6 = SyntaxNode.new(input, i6...index, s6)
          end
          s0 << r6
          if r6
            s11, i11 = [], index
            loop do
              r12 = _nt_newline
              if r12
                s11 << r12
              else
                break
              end
            end
            r11 = SyntaxNode.new(input, i11...index, s11)
            s0 << r11
            if r11
              r13 = _nt_blanks
              s0 << r13
            end
          end
        end
      end
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(Step1)
      r0.extend(Step2)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:step][start_index] = r0

    return r0
  end

  module GivenScenario0
  end

  module GivenScenario1
    def given_scenario_keyword
      elements[0]
    end

    def name
      elements[3]
    end

    def blanks
      elements[5]
    end
  end

  module GivenScenario2
    def populate(scenario)
      line = input.line_of(interval.first)
      scenario.add_given_scenario(name.text_value.strip, line)
    end
  end

  def _nt_given_scenario
    start_index = index
    if node_cache[:given_scenario].has_key?(index)
      cached = node_cache[:given_scenario][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_given_scenario_keyword
    s0 << r1
    if r1
      if input.index(":", index) == index
        r3 = (SyntaxNode).new(input, index...(index + 1))
        @index += 1
      else
        terminal_parse_failure(":")
        r3 = nil
      end
      if r3
        r2 = r3
      else
        r2 = SyntaxNode.new(input, index...index)
      end
      s0 << r2
      if r2
        s4, i4 = [], index
        loop do
          r5 = _nt_whitespace
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
          s6, i6 = [], index
          loop do
            i7, s7 = index, []
            i8 = index
            r9 = _nt_newline
            if r9
              r8 = nil
            else
              self.index = i8
              r8 = SyntaxNode.new(input, index...index)
            end
            s7 << r8
            if r8
              if index < input_length
                r10 = (SyntaxNode).new(input, index...(index + 1))
                @index += 1
              else
                terminal_parse_failure("any character")
                r10 = nil
              end
              s7 << r10
            end
            if s7.last
              r7 = (SyntaxNode).new(input, i7...index, s7)
              r7.extend(GivenScenario0)
            else
              self.index = i7
              r7 = nil
            end
            if r7
              s6 << r7
            else
              break
            end
          end
          if s6.empty?
            self.index = i6
            r6 = nil
          else
            r6 = SyntaxNode.new(input, i6...index, s6)
          end
          s0 << r6
          if r6
            s11, i11 = [], index
            loop do
              r12 = _nt_newline
              if r12
                s11 << r12
              else
                break
              end
            end
            r11 = SyntaxNode.new(input, i11...index, s11)
            s0 << r11
            if r11
              r13 = _nt_blanks
              s0 << r13
            end
          end
        end
      end
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(GivenScenario1)
      r0.extend(GivenScenario2)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:given_scenario][start_index] = r0

    return r0
  end

  def _nt_step_keyword
    start_index = index
    if node_cache[:step_keyword].has_key?(index)
      cached = node_cache[:step_keyword][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0 = index
    if input.index('Gitt', index) == index
      r1 = (SyntaxNode).new(input, index...(index + 4))
      @index += 4
    else
      terminal_parse_failure('Gitt')
      r1 = nil
    end
    if r1
      r0 = r1
    else
      if input.index('Når', index) == index
        r2 = (SyntaxNode).new(input, index...(index + 4))
        @index += 4
      else
        terminal_parse_failure('Når')
        r2 = nil
      end
      if r2
        r0 = r2
      else
        if input.index('Så', index) == index
          r3 = (SyntaxNode).new(input, index...(index + 3))
          @index += 3
        else
          terminal_parse_failure('Så')
          r3 = nil
        end
        if r3
          r0 = r3
        else
          if input.index('Og', index) == index
            r4 = (SyntaxNode).new(input, index...(index + 2))
            @index += 2
          else
            terminal_parse_failure('Og')
            r4 = nil
          end
          if r4
            r0 = r4
          else
            self.index = i0
            r0 = nil
          end
        end
      end
    end

    node_cache[:step_keyword][start_index] = r0

    return r0
  end

  def _nt_scenario_keyword
    start_index = index
    if node_cache[:scenario_keyword].has_key?(index)
      cached = node_cache[:scenario_keyword][index]
      @index = cached.interval.end if cached
      return cached
    end

    if input.index('Scenario', index) == index
      r0 = (SyntaxNode).new(input, index...(index + 8))
      @index += 8
    else
      terminal_parse_failure('Scenario')
      r0 = nil
    end

    node_cache[:scenario_keyword][start_index] = r0

    return r0
  end

  def _nt_given_scenario_keyword
    start_index = index
    if node_cache[:given_scenario_keyword].has_key?(index)
      cached = node_cache[:given_scenario_keyword][index]
      @index = cached.interval.end if cached
      return cached
    end

    if input.index('GittScenario', index) == index
      r0 = (SyntaxNode).new(input, index...(index + 12))
      @index += 12
    else
      terminal_parse_failure('GittScenario')
      r0 = nil
    end

    node_cache[:given_scenario_keyword][start_index] = r0

    return r0
  end

  module Table0
    def newline
      elements[0]
    end

    def table_line
      elements[1]
    end
  end

  module Table1
    def table_line
      elements[0]
    end

    def more
      elements[1]
    end

  end

  module Table2
    def populate(feature)
      Feature.last_scenario.table_header = table_line.values
      more.elements.each do |e|
        feature.add_row_scenario(Feature.last_scenario, e.table_line.values, e.table_line.line)
      end
    end
  end

  def _nt_table
    start_index = index
    if node_cache[:table].has_key?(index)
      cached = node_cache[:table][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_table_line
    s0 << r1
    if r1
      s2, i2 = [], index
      loop do
        i3, s3 = index, []
        r4 = _nt_newline
        s3 << r4
        if r4
          r5 = _nt_table_line
          s3 << r5
        end
        if s3.last
          r3 = (SyntaxNode).new(input, i3...index, s3)
          r3.extend(Table0)
        else
          self.index = i3
          r3 = nil
        end
        if r3
          s2 << r3
        else
          break
        end
      end
      if s2.empty?
        self.index = i2
        r2 = nil
      else
        r2 = SyntaxNode.new(input, i2...index, s2)
      end
      s0 << r2
      if r2
        s6, i6 = [], index
        loop do
          r7 = _nt_newline
          if r7
            s6 << r7
          else
            break
          end
        end
        r6 = SyntaxNode.new(input, i6...index, s6)
        s0 << r6
      end
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(Table1)
      r0.extend(Table2)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:table][start_index] = r0

    return r0
  end

  module TableLine0
    def cell_value
      elements[1]
    end

    def separator
      elements[3]
    end
  end

  module TableLine1
    def separator
      elements[1]
    end

    def cells
      elements[2]
    end
  end

  module TableLine2
    def values
      cells.elements.map { |cell| cell.cell_value.text_value.strip }
    end
    
    def line
      input.line_of(interval.first)
    end
  end

  def _nt_table_line
    start_index = index
    if node_cache[:table_line].has_key?(index)
      cached = node_cache[:table_line][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    s1, i1 = [], index
    loop do
      r2 = _nt_whitespace
      if r2
        s1 << r2
      else
        break
      end
    end
    r1 = SyntaxNode.new(input, i1...index, s1)
    s0 << r1
    if r1
      r3 = _nt_separator
      s0 << r3
      if r3
        s4, i4 = [], index
        loop do
          i5, s5 = index, []
          s6, i6 = [], index
          loop do
            r7 = _nt_whitespace
            if r7
              s6 << r7
            else
              break
            end
          end
          r6 = SyntaxNode.new(input, i6...index, s6)
          s5 << r6
          if r6
            r8 = _nt_cell_value
            s5 << r8
            if r8
              s9, i9 = [], index
              loop do
                r10 = _nt_whitespace
                if r10
                  s9 << r10
                else
                  break
                end
              end
              r9 = SyntaxNode.new(input, i9...index, s9)
              s5 << r9
              if r9
                r11 = _nt_separator
                s5 << r11
              end
            end
          end
          if s5.last
            r5 = (SyntaxNode).new(input, i5...index, s5)
            r5.extend(TableLine0)
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
      end
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(TableLine1)
      r0.extend(TableLine2)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:table_line][start_index] = r0

    return r0
  end

  module CellValue0
  end

  def _nt_cell_value
    start_index = index
    if node_cache[:cell_value].has_key?(index)
      cached = node_cache[:cell_value][index]
      @index = cached.interval.end if cached
      return cached
    end

    s0, i0 = [], index
    loop do
      i1, s1 = index, []
      i2 = index
      i3 = index
      r4 = _nt_separator
      if r4
        r3 = r4
      else
        r5 = _nt_newline
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
        r1.extend(CellValue0)
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

    node_cache[:cell_value][start_index] = r0

    return r0
  end

  def _nt_separator
    start_index = index
    if node_cache[:separator].has_key?(index)
      cached = node_cache[:separator][index]
      @index = cached.interval.end if cached
      return cached
    end

    if input.index('|', index) == index
      r0 = (SyntaxNode).new(input, index...(index + 1))
      @index += 1
    else
      terminal_parse_failure('|')
      r0 = nil
    end

    node_cache[:separator][start_index] = r0

    return r0
  end

  def _nt_blanks
    start_index = index
    if node_cache[:blanks].has_key?(index)
      cached = node_cache[:blanks][index]
      @index = cached.interval.end if cached
      return cached
    end

    s0, i0 = [], index
    loop do
      i1 = index
      r2 = _nt_newline
      if r2
        r1 = r2
      else
        r3 = _nt_whitespace
        if r3
          r1 = r3
        else
          self.index = i1
          r1 = nil
        end
      end
      if r1
        s0 << r1
      else
        break
      end
    end
    r0 = SyntaxNode.new(input, i0...index, s0)

    node_cache[:blanks][start_index] = r0

    return r0
  end

  def _nt_newline
    start_index = index
    if node_cache[:newline].has_key?(index)
      cached = node_cache[:newline][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0 = index
    if input.index("\r\n?", index) == index
      r1 = (SyntaxNode).new(input, index...(index + 3))
      @index += 3
    else
      terminal_parse_failure("\r\n?")
      r1 = nil
    end
    if r1
      r0 = r1
    else
      if input.index("\n", index) == index
        r2 = (SyntaxNode).new(input, index...(index + 1))
        @index += 1
      else
        terminal_parse_failure("\n")
        r2 = nil
      end
      if r2
        r0 = r2
      else
        self.index = i0
        r0 = nil
      end
    end

    node_cache[:newline][start_index] = r0

    return r0
  end

  def _nt_whitespace
    start_index = index
    if node_cache[:whitespace].has_key?(index)
      cached = node_cache[:whitespace][index]
      @index = cached.interval.end if cached
      return cached
    end

    if input.index(Regexp.new('[ \\t]'), index) == index
      r0 = (SyntaxNode).new(input, index...(index + 1))
      @index += 1
    else
      r0 = nil
    end

    node_cache[:whitespace][start_index] = r0

    return r0
  end

end

class FeatureParser < Treetop::Runtime::CompiledParser
  include Feature
end


end
end