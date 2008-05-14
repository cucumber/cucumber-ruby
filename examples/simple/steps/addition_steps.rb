require 'spec'

class Calculator
  def push(n)
    @args ||= []
    @args << n
  end
  
  def add
    @args.inject(0){|n,sum| sum+=n}
    raise "yo"
  end
end

Before do
  @calc = Calculator.new
end

After do
end

Given /I have entered (\d+)/ do |n|
  @calc.push n.to_i
end

When 'I add' do
  @result = @calc.add
end

Then /the result should be (\d*)/ do |result|
  @result.should == result.to_i
end
