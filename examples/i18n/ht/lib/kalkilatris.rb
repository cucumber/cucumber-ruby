# frozen_string_literal: true

class Kalkilatris
  def initialize
    @stack = []
  end

  def push(arg)
    @stack.push(arg)
  end

  def ajoute
    @stack.inject(0) { |n, sum| sum + n }
  end

  def divize
    @stack[0].to_f / @stack[1]
  end
end
