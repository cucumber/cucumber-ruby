# frozen_string_literal: true

class Calculator
  def initialize
    @stack = []
  end

  def push(arg)
    @stack.push(arg)
  end

  def חבר
    @stack.inject(0) { |n, sum| sum + n }
  end

  def חלק
    @stack[0].to_f / @stack[1]
  end
end
