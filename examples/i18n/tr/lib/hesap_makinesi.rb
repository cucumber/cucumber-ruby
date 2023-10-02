# frozen_string_literal: true

class HesapMakinesi
  def initialize
    @stack = []
  end

  def push(arg)
    @stack.push(arg)
  end

  def topla
    @stack.inject(0) { |n, sum| sum + n }
  end

  def böl
    @stack[0].to_f / @stack[1]
  end
end
