require 'spec'

class Calculator
  def push(n)
    @args ||= []
    @args << n
  end
  
  def add
    @args.inject(0){|n,sum| sum+=n}
  end
end

Before do
  @calc = Calculator.new
end

After do
end

Given /at jeg har tastet inn (\d+)/ do |n|
  @calc.push n.to_i
end

When 'jeg summerer' do
  @result = @calc.add
end

Then /skal resultatet være (\d*)/ do |result|
  @result.should == result.to_i
end
