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
    @stack.push @stack.pop + @stack.pop
  end

  def /
    divisor = @stack.pop
    dividend = @stack.pop
    # Hm, @stack.pop(2) doesn't work
    @stack.push dividend / divisor
  end
end
