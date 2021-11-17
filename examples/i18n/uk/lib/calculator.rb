class Calculator
  def initialize
    @stack = []
  end

  def push(arg)
    @stack.push arg
  end

  def result
    @stack.last
  end

  def +
    number_1 = @stack.pop
    number_2 = @stack.pop

    @stack.push number_1 + number_2
  end

  def /
    divisor = @stack.pop
    dividend = @stack.pop

    @stack.push dividend / divisor
  end
end
