# frozen_string_literal: true

class Kalkulaator
  def initialize
    @stack = []
  end

  def push(arg)
    @stack.push(arg)
  end

  def liida
    @stack.inject(0) { |n, sum| sum + n }
  end

  def jaga
    @stack[0].to_f / @stack[1]
  end
end
