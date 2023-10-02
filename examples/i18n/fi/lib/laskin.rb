# frozen_string_literal: true

class Laskin
  def initialize
    @stack = []
  end

  def push(arg)
    @stack.push(arg)
  end

  def summaa
    @stack.inject(0) { |n, sum| sum + n }
  end

  def jaa
    @stack[0].to_f / @stack[1]
  end
end
