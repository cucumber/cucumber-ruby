# frozen_string_literal: true

class Calculator
  def initialize
    @stack = []
  end

  def push(arg)
    @stack.push(arg)
  end

  def result
    @stack.last
  end

  def +
    number1 = @stack.pop
    number2 = @stack.pop

    @stack.push(number1 + number2)
  end

  def /
    divisor = @stack.pop
    dividend = @stack.pop

    @stack.push(dividend / divisor)
  end
end
