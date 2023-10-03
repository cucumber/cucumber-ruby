# frozen_string_literal: true

class Calculatrice
  def initialize
    @stack = []
  end

  def push(arg)
    @stack.push(arg)
  end

  def additionner
    @stack.inject(0) { |n, sum| sum + n }
  end
end
