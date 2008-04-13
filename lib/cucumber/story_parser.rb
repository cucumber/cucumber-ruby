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
      r0 = (Cucumber::Story).new(input, i0...index, s0)
      r0.extend(Story0)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:story][start_index] = r0

    return r0
  end

  module Header0
    def sentence_line
      elements[1]
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
    if input.index('Story: ', index) == index
      r1 = (SyntaxNode).new(input, index...(index + 7))
      @index += 7
    else
      terminal_parse_failure('Story: ')
      r1 = nil
    end
    s0 << r1
    if r1
      r2 = _nt_sentence_line
      s0 << r2
    end
    if s0.last
      r0 = (Cucumber::Header).new(input, i0...index, s0)
      r0.extend(Header0)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:header][start_index] = r0

    return r0
  end

  module Narrative0
    def sentence_line
      elements[1]
    end
  end

  def _nt_narrative
    start_index = index
    if node_cache[:narrative].has_key?(index)
      cached = node_cache[:narrative][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    if input.index('As a', index) == index
      r1 = (SyntaxNode).new(input, index...(index + 4))
      @index += 4
    else
      terminal_parse_failure('As a')
      r1 = nil
    end
    s0 << r1
    if r1
      r2 = _nt_sentence_line
      s0 << r2
    end
    if s0.last
      r0 = (Cucumber::Narrative).new(input, i0...index, s0)
      r0.extend(Narrative0)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:narrative][start_index] = r0

    return r0
  end

  module Scenario0
    def sentence_line
      elements[1]
    end

    def step_nodes
      elements[2]
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
    if input.index('Scenario: ', index) == index
      r1 = (SyntaxNode).new(input, index...(index + 10))
      @index += 10
    else
      terminal_parse_failure('Scenario: ')
      r1 = nil
    end
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
      r0 = (Cucumber::Scenario).new(input, i0...index, s0)
      r0.extend(Scenario0)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:scenario][start_index] = r0

    return r0
  end

  module Step0
    def sentence_line
      elements[1]
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
    i1 = index
    if input.index('Given ', index) == index
      r2 = (SyntaxNode).new(input, index...(index + 6))
      @index += 6
    else
      terminal_parse_failure('Given ')
      r2 = nil
    end
    if r2
      r1 = r2
    else
      if input.index('When ', index) == index
        r3 = (SyntaxNode).new(input, index...(index + 5))
        @index += 5
      else
        terminal_parse_failure('When ')
        r3 = nil
      end
      if r3
        r1 = r3
      else
        if input.index('Then ', index) == index
          r4 = (SyntaxNode).new(input, index...(index + 5))
          @index += 5
        else
          terminal_parse_failure('Then ')
          r4 = nil
        end
        if r4
          r1 = r4
        else
          self.index = i1
          r1 = nil
        end
      end
    end
    s0 << r1
    if r1
      r5 = _nt_sentence_line
      s0 << r5
    end
    if s0.last
      r0 = (Cucumber::Step).new(input, i0...index, s0)
      r0.extend(Step0)
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

