module Cucumber
module Story
  include Treetop::Runtime

  def root
    @root || :story
  end

  module Story0
    def header
      elements[0]
    end

    def narrative
      elements[1]
    end

    def scenario_nodes
      elements[2]
    end
  end

  module Story1
    def eval(story_handler)
      header.eval(story_handler)
      narrative.eval(story_handler)
      scenario_nodes.elements.each do |scenario_node|
        scenario_node.eval(story_handler)
      end
    end
  end

  def _nt_story
    start_index = index
    if node_cache[:story].has_key?(index)
      cached = node_cache[:story][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_header
    s0 << r1
    if r1
      r2 = _nt_narrative
      s0 << r2
      if r2
        s3, i3 = [], index
        loop do
          r4 = _nt_scenario
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
      r0.extend(Story0)
      r0.extend(Story1)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:story][start_index] = r0

    return r0
  end

  module Header0
    def space
      elements[1]
    end

    def sentence_line
      elements[2]
    end
  end

  module Header1
    def eval(story_handler)
      story_handler.story(sentence_line.text_value.strip)
    end
  end

  def _nt_header
    start_index = index
    if node_cache[:header].has_key?(index)
      cached = node_cache[:header][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    if input.index('Historie:', index) == index
      r1 = (SyntaxNode).new(input, index...(index + 9))
      @index += 9
    else
      terminal_parse_failure('Historie:')
      r1 = nil
    end
    s0 << r1
    if r1
      r2 = _nt_space
      s0 << r2
      if r2
        r3 = _nt_sentence_line
        s0 << r3
      end
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(Header0)
      r0.extend(Header1)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:header][start_index] = r0

    return r0
  end

  module Narrative0
  end

  module Narrative1
    def eval(story_handler)
      story_handler.narrative(self.text_value)
    end
  end

  def _nt_narrative
    start_index = index
    if node_cache[:narrative].has_key?(index)
      cached = node_cache[:narrative][index]
      @index = cached.interval.end if cached
      return cached
    end

    s0, i0 = [], index
    loop do
      i1, s1 = index, []
      i2 = index
      r3 = _nt_scenario_start
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
        r1.extend(Narrative0)
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
    r0.extend(Narrative1)

    node_cache[:narrative][start_index] = r0

    return r0
  end

  module Scenario0
    def scenario_start
      elements[0]
    end

    def sentence
      elements[1]
    end

    def step_nodes
      elements[2]
    end
  end

  module Scenario1
    def eval(story_handler)
      story_handler.scenario(sentence.text_value.strip)
      step_nodes.elements.each do |step_node|
        step_node.eval(story_handler)
      end
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
    r1 = _nt_scenario_start
    s0 << r1
    if r1
      r2 = _nt_sentence_line
      s0 << r2
      if r2
        s3, i3 = [], index
        loop do
          r4 = _nt_step
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
      r0.extend(Scenario0)
      r0.extend(Scenario1)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:scenario][start_index] = r0

    return r0
  end

  module ScenarioStart0
    def space
      elements[0]
    end

  end

  def _nt_scenario_start
    start_index = index
    if node_cache[:scenario_start].has_key?(index)
      cached = node_cache[:scenario_start][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_space
    s0 << r1
    if r1
      if input.index('Scenario: ', index) == index
        r2 = (SyntaxNode).new(input, index...(index + 10))
        @index += 10
      else
        terminal_parse_failure('Scenario: ')
        r2 = nil
      end
      s0 << r2
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(ScenarioStart0)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:scenario_start][start_index] = r0

    return r0
  end

  module Step0
    def space
      elements[0]
    end

    def step_type
      elements[1]
    end

    def space
      elements[2]
    end

    def sentence
      elements[3]
    end
  end

  module Step1
    def eval(story_handler)
      story_handler.step(step_type.text_value.strip, sentence.text_value.strip, input.line_of(interval.first))
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
    r1 = _nt_space
    s0 << r1
    if r1
      i2 = index
      if input.index('Gitt', index) == index
        r3 = (SyntaxNode).new(input, index...(index + 4))
        @index += 4
      else
        terminal_parse_failure('Gitt')
        r3 = nil
      end
      if r3
        r2 = r3
      else
        if input.index('Når', index) == index
          r4 = (SyntaxNode).new(input, index...(index + 4))
          @index += 4
        else
          terminal_parse_failure('Når')
          r4 = nil
        end
        if r4
          r2 = r4
        else
          if input.index('Så', index) == index
            r5 = (SyntaxNode).new(input, index...(index + 3))
            @index += 3
          else
            terminal_parse_failure('Så')
            r5 = nil
          end
          if r5
            r2 = r5
          else
            if input.index('GittScenario', index) == index
              r6 = (SyntaxNode).new(input, index...(index + 12))
              @index += 12
            else
              terminal_parse_failure('GittScenario')
              r6 = nil
            end
            if r6
              r2 = r6
            else
              self.index = i2
              r2 = nil
            end
          end
        end
      end
      s0 << r2
      if r2
        r7 = _nt_space
        s0 << r7
        if r7
          r8 = _nt_sentence_line
          s0 << r8
        end
      end
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(Step0)
      r0.extend(Step1)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:step][start_index] = r0

    return r0
  end

  module SentenceLine0
  end

  module SentenceLine1
    def eol
      elements[1]
    end
  end

  def _nt_sentence_line
    start_index = index
    if node_cache[:sentence_line].has_key?(index)
      cached = node_cache[:sentence_line][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    s1, i1 = [], index
    loop do
      i2, s2 = index, []
      i3 = index
      r4 = _nt_eol
      if r4
        r3 = nil
      else
        self.index = i3
        r3 = SyntaxNode.new(input, index...index)
      end
      s2 << r3
      if r3
        if index < input_length
          r5 = (SyntaxNode).new(input, index...(index + 1))
          @index += 1
        else
          terminal_parse_failure("any character")
          r5 = nil
        end
        s2 << r5
      end
      if s2.last
        r2 = (SyntaxNode).new(input, i2...index, s2)
        r2.extend(SentenceLine0)
      else
        self.index = i2
        r2 = nil
      end
      if r2
        s1 << r2
      else
        break
      end
    end
    r1 = SyntaxNode.new(input, i1...index, s1)
    s0 << r1
    if r1
      r6 = _nt_eol
      s0 << r6
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(SentenceLine1)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:sentence_line][start_index] = r0

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
      if input.index(Regexp.new('[ \\n]'), index) == index
        r1 = (SyntaxNode).new(input, index...(index + 1))
        @index += 1
      else
        r1 = nil
      end
      if r1
        s0 << r1
      else
        break
      end
    end
    r0 = SyntaxNode.new(input, i0...index, s0)

    node_cache[:space][start_index] = r0

    return r0
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
      r2 = _nt_eof
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

class StoryParser < Treetop::Runtime::CompiledParser
  include Story
end


end