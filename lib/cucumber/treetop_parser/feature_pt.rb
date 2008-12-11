module Cucumber
# :stopdoc:
module TreetopParser
module Feature
  include Treetop::Runtime

  def root
    @root || :root
  end

  module Root0
    def header
      elements[1]
    end

    def scenario_sequence
      elements[2]
    end

  end

  module Root1
    def compile
      feature = Tree::Feature.new(header.text_value.strip)
      scenario_sequence.compile(feature)
      feature
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
    r2 = _nt_space
    if r2
      r1 = r2
    else
      r1 = SyntaxNode.new(input, index...index)
    end
    s0 << r1
    if r1
      r3 = _nt_header
      s0 << r3
      if r3
        r4 = _nt_scenario_sequence
        s0 << r4
        if r4
          r6 = _nt_space
          if r6
            r5 = r6
          else
            r5 = SyntaxNode.new(input, index...index)
          end
          s0 << r5
        end
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
      i3 = index
      r4 = _nt_scenario_keyword
      if r4
        r3 = r4
      else
        r5 = _nt_scenario_outline_keyword
        if r5
          r3 = r5
        else
          r6 = _nt_comment_to_eol
          if r6
            r3 = r6
          else
            self.index = i3
            r3 = nil
          end
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
          r7 = (SyntaxNode).new(input, index...(index + 1))
          @index += 1
        else
          terminal_parse_failure("any character")
          r7 = nil
        end
        s1 << r7
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
    if s0.empty?
      self.index = i0
      r0 = nil
    else
      r0 = SyntaxNode.new(input, i0...index, s0)
    end

    node_cache[:header][start_index] = r0

    return r0
  end

  module ScenarioSequence0
    def space
      elements[0]
    end

    def scenario_or_scenario_outline_or_table
      elements[1]
    end
  end

  module ScenarioSequence1
    def head
      elements[0]
    end

    def tail
      elements[1]
    end
  end

  module ScenarioSequence2
    def compile(feature)
      ([head] + tail).each do |scenario_or_scenario_outline_or_table|
        scenario_or_scenario_outline_or_table.compile(feature) if scenario_or_scenario_outline_or_table.respond_to?(:compile)
      end
    end
    
    def tail
      super.elements.map { |elt| elt.scenario_or_scenario_outline_or_table }
    end
  end

  def _nt_scenario_sequence
    start_index = index
    if node_cache[:scenario_sequence].has_key?(index)
      cached = node_cache[:scenario_sequence][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    r2 = _nt_scenario_outline_or_scenario
    if r2
      r1 = r2
    else
      r1 = SyntaxNode.new(input, index...index)
    end
    s0 << r1
    if r1
      s3, i3 = [], index
      loop do
        i4, s4 = index, []
        r5 = _nt_space
        s4 << r5
        if r5
          r6 = _nt_scenario_or_scenario_outline_or_table
          s4 << r6
        end
        if s4.last
          r4 = (SyntaxNode).new(input, i4...index, s4)
          r4.extend(ScenarioSequence0)
        else
          self.index = i4
          r4 = nil
        end
        if r4
          s3 << r4
        else
          break
        end
      end
      r3 = SyntaxNode.new(input, i3...index, s3)
      s0 << r3
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(ScenarioSequence1)
      r0.extend(ScenarioSequence2)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:scenario_sequence][start_index] = r0

    return r0
  end

  def _nt_scenario_outline_or_scenario
    start_index = index
    if node_cache[:scenario_outline_or_scenario].has_key?(index)
      cached = node_cache[:scenario_outline_or_scenario][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0 = index
    r1 = _nt_scenario_outline
    if r1
      r0 = r1
    else
      r2 = _nt_scenario
      if r2
        r0 = r2
      else
        self.index = i0
        r0 = nil
      end
    end

    node_cache[:scenario_outline_or_scenario][start_index] = r0

    return r0
  end

  module Scenario0
    def space
      elements[0]
    end

    def step_sequence
      elements[1]
    end
  end

  module Scenario1
    def scenario_keyword
      elements[0]
    end

    def name
      elements[2]
    end

    def steps
      elements[3]
    end
  end

  module Scenario2
    def compile(feature)
      line = input.line_of(interval.first)
      scenario = feature.add_scenario(name.text_value.strip, line)
      steps.step_sequence.compile(scenario) if steps.respond_to?(:step_sequence)
      # TODO - GET RID OF THIS last_scenario NASTINESS
      # Use a better datastructure, like a linked list...
      Feature.last_scenario = scenario
    end
  end

  def _nt_scenario
    start_index = index
    if node_cache[:scenario].has_key?(index)
      cached = node_cache[:scenario][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_scenario_keyword
    s0 << r1
    if r1
      r3 = _nt_space
      if r3
        r2 = r3
      else
        r2 = SyntaxNode.new(input, index...index)
      end
      s0 << r2
      if r2
        r4 = _nt_line_to_eol
        s0 << r4
        if r4
          i6, s6 = index, []
          r7 = _nt_space
          s6 << r7
          if r7
            r8 = _nt_step_sequence
            s6 << r8
          end
          if s6.last
            r6 = (SyntaxNode).new(input, i6...index, s6)
            r6.extend(Scenario0)
          else
            self.index = i6
            r6 = nil
          end
          if r6
            r5 = r6
          else
            r5 = SyntaxNode.new(input, index...index)
          end
          s0 << r5
        end
      end
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(Scenario1)
      r0.extend(Scenario2)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:scenario][start_index] = r0

    return r0
  end

  module ScenarioOutline0
    def scenario_outline_keyword
      elements[0]
    end

    def name
      elements[2]
    end

    def outline_body
      elements[3]
    end
  end

  module ScenarioOutline1
    def compile(feature)
      line = input.line_of(interval.first)
      scenario = feature.add_scenario_outline(name.text_value.strip, line)
      Feature.last_scenario = scenario
      outline_body.compile(feature, scenario) if outline_body.respond_to?(:compile)
    end
  end

  def _nt_scenario_outline
    start_index = index
    if node_cache[:scenario_outline].has_key?(index)
      cached = node_cache[:scenario_outline][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_scenario_outline_keyword
    s0 << r1
    if r1
      r3 = _nt_space
      if r3
        r2 = r3
      else
        r2 = SyntaxNode.new(input, index...index)
      end
      s0 << r2
      if r2
        r4 = _nt_line_to_eol
        s0 << r4
        if r4
          r6 = _nt_steps_and_optional_examples
          if r6
            r5 = r6
          else
            r5 = SyntaxNode.new(input, index...index)
          end
          s0 << r5
        end
      end
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(ScenarioOutline0)
      r0.extend(ScenarioOutline1)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:scenario_outline][start_index] = r0

    return r0
  end

  def _nt_scenario_or_scenario_outline_or_table
    start_index = index
    if node_cache[:scenario_or_scenario_outline_or_table].has_key?(index)
      cached = node_cache[:scenario_or_scenario_outline_or_table][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0 = index
    r1 = _nt_scenario_outline
    if r1
      r0 = r1
    else
      i2 = index
      r3 = _nt_scenario
      if r3
        r2 = r3
      else
        r4 = _nt_more_examples
        if r4
          r2 = r4
        else
          self.index = i2
          r2 = nil
        end
      end
      if r2
        r0 = r2
      else
        self.index = i0
        r0 = nil
      end
    end

    node_cache[:scenario_or_scenario_outline_or_table][start_index] = r0

    return r0
  end

  module StepsAndOptionalExamples0
    def space
      elements[0]
    end

    def step_sequence
      elements[1]
    end
  end

  module StepsAndOptionalExamples1
    def space
      elements[0]
    end

    def examples
      elements[1]
    end
  end

  module StepsAndOptionalExamples2
    def steps
      elements[0]
    end

    def table
      elements[1]
    end
  end

  module StepsAndOptionalExamples3
    def compile(feature, scenario)
      steps.step_sequence.compile(scenario) if steps.respond_to?(:step_sequence)
      table.examples.compile(feature, scenario) if table.respond_to?(:examples) && table.examples.respond_to?(:compile)
    end
  end

  def _nt_steps_and_optional_examples
    start_index = index
    if node_cache[:steps_and_optional_examples].has_key?(index)
      cached = node_cache[:steps_and_optional_examples][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    i1, s1 = index, []
    r2 = _nt_space
    s1 << r2
    if r2
      r3 = _nt_step_sequence
      s1 << r3
    end
    if s1.last
      r1 = (SyntaxNode).new(input, i1...index, s1)
      r1.extend(StepsAndOptionalExamples0)
    else
      self.index = i1
      r1 = nil
    end
    s0 << r1
    if r1
      i5, s5 = index, []
      r6 = _nt_space
      s5 << r6
      if r6
        r7 = _nt_examples
        s5 << r7
      end
      if s5.last
        r5 = (SyntaxNode).new(input, i5...index, s5)
        r5.extend(StepsAndOptionalExamples1)
      else
        self.index = i5
        r5 = nil
      end
      if r5
        r4 = r5
      else
        r4 = SyntaxNode.new(input, index...index)
      end
      s0 << r4
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(StepsAndOptionalExamples2)
      r0.extend(StepsAndOptionalExamples3)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:steps_and_optional_examples][start_index] = r0

    return r0
  end

  module MoreExamples0
    def more_examples_keyword
      elements[0]
    end

    def table
      elements[1]
    end
  end

  module MoreExamples1
    def compile(f)
      table.compile(f)
    end
  end

  def _nt_more_examples
    start_index = index
    if node_cache[:more_examples].has_key?(index)
      cached = node_cache[:more_examples][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_more_examples_keyword
    s0 << r1
    if r1
      r2 = _nt_table
      s0 << r2
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(MoreExamples0)
      r0.extend(MoreExamples1)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:more_examples][start_index] = r0

    return r0
  end

  module Examples0
    def examples_keyword
      elements[0]
    end

    def table
      elements[1]
    end
  end

  module Examples1
    def compile(feature, scenario)
      table.compile_examples(feature, scenario)
    end
  end

  def _nt_examples
    start_index = index
    if node_cache[:examples].has_key?(index)
      cached = node_cache[:examples][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_examples_keyword
    s0 << r1
    if r1
      r2 = _nt_table
      s0 << r2
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(Examples0)
      r0.extend(Examples1)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:examples][start_index] = r0

    return r0
  end

  module Table0
    def eol
      elements[1]
    end

    def table_line
      elements[3]
    end
  end

  module Table1
    def space
      elements[0]
    end

    def head
      elements[1]
    end

    def body
      elements[2]
    end
  end

  module Table2
    def compile(feature)
      Feature.last_scenario.table_header = head.cell_values
      body.each do |table_line|
        feature.add_row_scenario(Feature.last_scenario, table_line.cell_values, table_line.line)
      end
    end
    
    def compile_examples(feature, scenario)
      scenario.table_header = head.cell_values
      body.each do |table_line|
        feature.add_row_scenario_outline(scenario, table_line.cell_values, table_line.line)
      end
    end
    
    def matrix
      ([head] + body).map do |table_line|
        table_line.cell_values # We're losing the line - we'll get it back when we make our own class
      end
    end
    
    def to_arg
      Model::Table.new(matrix)
    end
    
    def body
      super.elements.map { |elt| elt.table_line }
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
    r1 = _nt_space
    s0 << r1
    if r1
      r2 = _nt_table_line
      s0 << r2
      if r2
        s3, i3 = [], index
        loop do
          i4, s4 = index, []
          s5, i5 = [], index
          loop do
            r6 = _nt_blank
            if r6
              s5 << r6
            else
              break
            end
          end
          r5 = SyntaxNode.new(input, i5...index, s5)
          s4 << r5
          if r5
            r7 = _nt_eol
            s4 << r7
            if r7
              r9 = _nt_space
              if r9
                r8 = r9
              else
                r8 = SyntaxNode.new(input, index...index)
              end
              s4 << r8
              if r8
                r10 = _nt_table_line
                s4 << r10
              end
            end
          end
          if s4.last
            r4 = (SyntaxNode).new(input, i4...index, s4)
            r4.extend(Table0)
          else
            self.index = i4
            r4 = nil
          end
          if r4
            s3 << r4
          else
            break
          end
        end
        r3 = SyntaxNode.new(input, i3...index, s3)
        s0 << r3
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
      elements[0]
    end

    def cells
      elements[1]
    end
  end

  module TableLine2
    def cell_values
      cells.elements.map { |elt| elt.cell_value.text_value.strip }
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
    r1 = _nt_separator
    s0 << r1
    if r1
      s2, i2 = [], index
      loop do
        i3, s3 = index, []
        s4, i4 = [], index
        loop do
          r5 = _nt_blank
          if r5
            s4 << r5
          else
            break
          end
        end
        r4 = SyntaxNode.new(input, i4...index, s4)
        s3 << r4
        if r4
          r6 = _nt_cell_value
          s3 << r6
          if r6
            s7, i7 = [], index
            loop do
              r8 = _nt_blank
              if r8
                s7 << r8
              else
                break
              end
            end
            r7 = SyntaxNode.new(input, i7...index, s7)
            s3 << r7
            if r7
              r9 = _nt_separator
              s3 << r9
            end
          end
        end
        if s3.last
          r3 = (SyntaxNode).new(input, i3...index, s3)
          r3.extend(TableLine0)
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

  module StepSequence0
    def space
      elements[0]
    end

    def step
      elements[1]
    end
  end

  module StepSequence1
    def head
      elements[0]
    end

    def tail
      elements[1]
    end
  end

  module StepSequence2
    def compile(scenario)
      ([head] + tail).each do |step|
        step.compile(scenario)
      end
    end
    
    def tail
      super.elements.map { |elt| elt.step }
    end
  end

  def _nt_step_sequence
    start_index = index
    if node_cache[:step_sequence].has_key?(index)
      cached = node_cache[:step_sequence][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_step
    s0 << r1
    if r1
      s2, i2 = [], index
      loop do
        i3, s3 = index, []
        r4 = _nt_space
        s3 << r4
        if r4
          r5 = _nt_step
          s3 << r5
        end
        if s3.last
          r3 = (SyntaxNode).new(input, i3...index, s3)
          r3.extend(StepSequence0)
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
      r2 = SyntaxNode.new(input, i2...index, s2)
      s0 << r2
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(StepSequence1)
      r0.extend(StepSequence2)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:step_sequence][start_index] = r0

    return r0
  end

  def _nt_step
    start_index = index
    if node_cache[:step].has_key?(index)
      cached = node_cache[:step][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0 = index
    r1 = _nt_given_scenario
    if r1
      r0 = r1
    else
      r2 = _nt_plain_step
      if r2
        r0 = r2
      else
        self.index = i0
        r0 = nil
      end
    end

    node_cache[:step][start_index] = r0

    return r0
  end

  module GivenScenario0
    def given_scenario_keyword
      elements[0]
    end

    def name
      elements[2]
    end
  end

  module GivenScenario1
    def compile(scenario)
      line = input.line_of(interval.first)
      scenario.create_given_scenario(name.text_value.strip, line)
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
      r3 = _nt_space
      if r3
        r2 = r3
      else
        r2 = SyntaxNode.new(input, index...index)
      end
      s0 << r2
      if r2
        r4 = _nt_line_to_eol
        s0 << r4
      end
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(GivenScenario0)
      r0.extend(GivenScenario1)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:given_scenario][start_index] = r0

    return r0
  end

  module PlainStep0
    def step_keyword
      elements[0]
    end

    def name
      elements[2]
    end

    def multi
      elements[3]
    end
  end

  module PlainStep1
    def compile(scenario)
      line = input.line_of(interval.first)
      step = scenario.create_step(step_keyword.text_value, name.text_value.strip, line)

      if multi.respond_to?(:to_arg)
        step.extra_args << multi.to_arg
      end
    end
  end

  def _nt_plain_step
    start_index = index
    if node_cache[:plain_step].has_key?(index)
      cached = node_cache[:plain_step][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_step_keyword
    s0 << r1
    if r1
      r3 = _nt_space
      if r3
        r2 = r3
      else
        r2 = SyntaxNode.new(input, index...index)
      end
      s0 << r2
      if r2
        r4 = _nt_line_to_eol
        s0 << r4
        if r4
          r6 = _nt_multiline_arg
          if r6
            r5 = r6
          else
            r5 = SyntaxNode.new(input, index...index)
          end
          s0 << r5
        end
      end
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(PlainStep0)
      r0.extend(PlainStep1)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:plain_step][start_index] = r0

    return r0
  end

  def _nt_multiline_arg
    start_index = index
    if node_cache[:multiline_arg].has_key?(index)
      cached = node_cache[:multiline_arg][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0 = index
    r1 = _nt_table
    if r1
      r0 = r1
    else
      r2 = _nt_multiline_string
      if r2
        r0 = r2
      else
        self.index = i0
        r0 = nil
      end
    end

    node_cache[:multiline_arg][start_index] = r0

    return r0
  end

  module MultilineString0
  end

  module MultilineString1
    def eol
      elements[0]
    end

    def indent
      elements[1]
    end

    def triple_quote
      elements[2]
    end

    def string
      elements[3]
    end

    def triple_quote
      elements[4]
    end
  end

  module MultilineString2
    def to_arg
      indent_length = indent.text_value.length
      significant_lines = string.text_value.split("\n")[1..-2]
      significant_lines.map do |l| 
        l[indent_length..-1]
      end.join("\n")
    end
  end

  def _nt_multiline_string
    start_index = index
    if node_cache[:multiline_string].has_key?(index)
      cached = node_cache[:multiline_string][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_eol
    s0 << r1
    if r1
      r2 = _nt_space
      s0 << r2
      if r2
        r3 = _nt_triple_quote
        s0 << r3
        if r3
          s4, i4 = [], index
          loop do
            i5, s5 = index, []
            i6 = index
            r7 = _nt_triple_quote
            if r7
              r6 = nil
            else
              self.index = i6
              r6 = SyntaxNode.new(input, index...index)
            end
            s5 << r6
            if r6
              if index < input_length
                r8 = (SyntaxNode).new(input, index...(index + 1))
                @index += 1
              else
                terminal_parse_failure("any character")
                r8 = nil
              end
              s5 << r8
            end
            if s5.last
              r5 = (SyntaxNode).new(input, i5...index, s5)
              r5.extend(MultilineString0)
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
          r4 = SyntaxNode.new(input, i4...index, s4)
          s0 << r4
          if r4
            r9 = _nt_triple_quote
            s0 << r9
          end
        end
      end
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(MultilineString1)
      r0.extend(MultilineString2)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:multiline_string][start_index] = r0

    return r0
  end

  def _nt_triple_quote
    start_index = index
    if node_cache[:triple_quote].has_key?(index)
      cached = node_cache[:triple_quote][index]
      @index = cached.interval.end if cached
      return cached
    end

    if input.index('"""', index) == index
      r0 = (SyntaxNode).new(input, index...(index + 3))
      @index += 3
    else
      terminal_parse_failure('"""')
      r0 = nil
    end

    node_cache[:triple_quote][start_index] = r0

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

  def _nt_space
    start_index = index
    if node_cache[:space].has_key?(index)
      cached = node_cache[:space][index]
      @index = cached.interval.end if cached
      return cached
    end

    s0, i0 = [], index
    loop do
      i1 = index
      r2 = _nt_white
      if r2
        r1 = r2
      else
        r3 = _nt_comment_to_eol
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
    if s0.empty?
      self.index = i0
      r0 = nil
    else
      r0 = SyntaxNode.new(input, i0...index, s0)
    end

    node_cache[:space][start_index] = r0

    return r0
  end

  module LineToEol0
  end

  def _nt_line_to_eol
    start_index = index
    if node_cache[:line_to_eol].has_key?(index)
      cached = node_cache[:line_to_eol][index]
      @index = cached.interval.end if cached
      return cached
    end

    s0, i0 = [], index
    loop do
      i1, s1 = index, []
      i2 = index
      r3 = _nt_eol
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
        r1.extend(LineToEol0)
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

    node_cache[:line_to_eol][start_index] = r0

    return r0
  end

  module CommentToEol0
    def line_to_eol
      elements[1]
    end
  end

  def _nt_comment_to_eol
    start_index = index
    if node_cache[:comment_to_eol].has_key?(index)
      cached = node_cache[:comment_to_eol][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    if input.index('#', index) == index
      r1 = (SyntaxNode).new(input, index...(index + 1))
      @index += 1
    else
      terminal_parse_failure('#')
      r1 = nil
    end
    s0 << r1
    if r1
      r2 = _nt_line_to_eol
      s0 << r2
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(CommentToEol0)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:comment_to_eol][start_index] = r0

    return r0
  end

  def _nt_white
    start_index = index
    if node_cache[:white].has_key?(index)
      cached = node_cache[:white][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0 = index
    r1 = _nt_blank
    if r1
      r0 = r1
    else
      r2 = _nt_eol
      if r2
        r0 = r2
      else
        self.index = i0
        r0 = nil
      end
    end

    node_cache[:white][start_index] = r0

    return r0
  end

  def _nt_blank
    start_index = index
    if node_cache[:blank].has_key?(index)
      cached = node_cache[:blank][index]
      @index = cached.interval.end if cached
      return cached
    end

    if input.index(Regexp.new('[ \\t]'), index) == index
      r0 = (SyntaxNode).new(input, index...(index + 1))
      @index += 1
    else
      r0 = nil
    end

    node_cache[:blank][start_index] = r0

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
    i1, s1 = index, []
    if input.index("\r", index) == index
      r2 = (SyntaxNode).new(input, index...(index + 1))
      @index += 1
    else
      terminal_parse_failure("\r")
      r2 = nil
    end
    s1 << r2
    if r2
      if input.index("\n", index) == index
        r4 = (SyntaxNode).new(input, index...(index + 1))
        @index += 1
      else
        terminal_parse_failure("\n")
        r4 = nil
      end
      if r4
        r3 = r4
      else
        r3 = SyntaxNode.new(input, index...index)
      end
      s1 << r3
    end
    if s1.last
      r1 = (SyntaxNode).new(input, i1...index, s1)
      r1.extend(Eol0)
    else
      self.index = i1
      r1 = nil
    end
    if r1
      r0 = r1
    else
      if input.index("\n", index) == index
        r5 = (SyntaxNode).new(input, index...(index + 1))
        @index += 1
      else
        terminal_parse_failure("\n")
        r5 = nil
      end
      if r5
        r0 = r5
      else
        self.index = i0
        r0 = nil
      end
    end

    node_cache[:eol][start_index] = r0

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
    if input.index("Dado", index) == index
      r1 = (SyntaxNode).new(input, index...(index + 4))
      @index += 4
    else
      terminal_parse_failure("Dado")
      r1 = nil
    end
    if r1
      r0 = r1
    else
      if input.index("Quando", index) == index
        r2 = (SyntaxNode).new(input, index...(index + 6))
        @index += 6
      else
        terminal_parse_failure("Quando")
        r2 = nil
      end
      if r2
        r0 = r2
      else
        if input.index("Então", index) == index
          r3 = (SyntaxNode).new(input, index...(index + 6))
          @index += 6
        else
          terminal_parse_failure("Então")
          r3 = nil
        end
        if r3
          r0 = r3
        else
          if input.index("E", index) == index
            r4 = (SyntaxNode).new(input, index...(index + 1))
            @index += 1
          else
            terminal_parse_failure("E")
            r4 = nil
          end
          if r4
            r0 = r4
          else
            if input.index("Mas", index) == index
              r5 = (SyntaxNode).new(input, index...(index + 3))
              @index += 3
            else
              terminal_parse_failure("Mas")
              r5 = nil
            end
            if r5
              r0 = r5
            else
              self.index = i0
              r0 = nil
            end
          end
        end
      end
    end

    node_cache[:step_keyword][start_index] = r0

    return r0
  end

  module ScenarioKeyword0
  end

  def _nt_scenario_keyword
    start_index = index
    if node_cache[:scenario_keyword].has_key?(index)
      cached = node_cache[:scenario_keyword][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    if input.index("Cenário", index) == index
      r1 = (SyntaxNode).new(input, index...(index + 8))
      @index += 8
    else
      terminal_parse_failure("Cenário")
      r1 = nil
    end
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
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(ScenarioKeyword0)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:scenario_keyword][start_index] = r0

    return r0
  end

  module ScenarioOutlineKeyword0
  end

  def _nt_scenario_outline_keyword
    start_index = index
    if node_cache[:scenario_outline_keyword].has_key?(index)
      cached = node_cache[:scenario_outline_keyword][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    if input.index("Scenario Outline", index) == index
      r1 = (SyntaxNode).new(input, index...(index + 16))
      @index += 16
    else
      terminal_parse_failure("Scenario Outline")
      r1 = nil
    end
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
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(ScenarioOutlineKeyword0)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:scenario_outline_keyword][start_index] = r0

    return r0
  end

  module MoreExamplesKeyword0
  end

  def _nt_more_examples_keyword
    start_index = index
    if node_cache[:more_examples_keyword].has_key?(index)
      cached = node_cache[:more_examples_keyword][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    if input.index("More Examples", index) == index
      r1 = (SyntaxNode).new(input, index...(index + 13))
      @index += 13
    else
      terminal_parse_failure("More Examples")
      r1 = nil
    end
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
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(MoreExamplesKeyword0)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:more_examples_keyword][start_index] = r0

    return r0
  end

  module ExamplesKeyword0
  end

  def _nt_examples_keyword
    start_index = index
    if node_cache[:examples_keyword].has_key?(index)
      cached = node_cache[:examples_keyword][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    if input.index("Examples", index) == index
      r1 = (SyntaxNode).new(input, index...(index + 8))
      @index += 8
    else
      terminal_parse_failure("Examples")
      r1 = nil
    end
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
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(ExamplesKeyword0)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:examples_keyword][start_index] = r0

    return r0
  end

  module GivenScenarioKeyword0
  end

  def _nt_given_scenario_keyword
    start_index = index
    if node_cache[:given_scenario_keyword].has_key?(index)
      cached = node_cache[:given_scenario_keyword][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    if input.index("DadoOCenário", index) == index
      r1 = (SyntaxNode).new(input, index...(index + 13))
      @index += 13
    else
      terminal_parse_failure("DadoOCenário")
      r1 = nil
    end
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
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(GivenScenarioKeyword0)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:given_scenario_keyword][start_index] = r0

    return r0
  end

end

class FeatureParser < Treetop::Runtime::CompiledParser
  include Feature
end


end
end