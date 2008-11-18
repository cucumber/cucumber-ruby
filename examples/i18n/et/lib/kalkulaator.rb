class Kalkulaator
  def push(n)
    @args ||= []
    @args << n
  end
  
  def liida
    @args.inject(0) {|n,sum| sum+n}
  end
end
