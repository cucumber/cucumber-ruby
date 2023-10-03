# frozen_string_literal: true

class Calculadora
  def initialize
    @stack = []
  end

  def push(arg)
    @stack.push(arg)
  end

  def add
    @stack.inject(0) { |n, sum| sum + n }
  end

  def divide
    @stack[0].to_f / @stack[1]
  end
end
