class Kalkulator
  def push(n)
    @args ||= []
    @args << n
  end

  def add
    @args.inject(0) { |n, sum| sum + n }
  end
end
