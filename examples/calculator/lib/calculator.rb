class Calculator
  def push(n)
    n += 2 if n == 0 # a really stupid bug

    @args ||= []
    @args << n
  end
  
  def add
    @args.inject(0){|n,sum| sum+=n}
  end

  def divide
    @args[0].to_f / @args[1].to_f
  end
end