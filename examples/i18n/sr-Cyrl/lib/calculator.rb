# frozen_string_literal: true

class Calculator
  def initialize
    @stack = []
  end

  def push(arg)
    @stack.push(arg)
  end

  def add
    @stack.inject(0) { |n, sum| sum + n }
  end
end
