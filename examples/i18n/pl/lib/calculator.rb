# frozen_string_literal: true

class Calculator
  def initialize
    @stack = []
  end

  def push(arg)
    @stack.push(arg)
  end

  def dodaj
    @stack.inject(0) { |n, sum| sum + n }
  end

  def podziel
    @stack[0].to_f / @stack[1]
  end
end
