# frozen_string_literal: true

class Calculadora
  def initialize
    @stack = []
  end

  def push(arg)
    @stack.push(arg)
  end

  def soma
    @stack.inject(0) { |n, sum| sum + n }
  end
end
