require 'spec'

class Calculator
  def push(n)
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

Before do
  @calc = Calculator.new
end

After do
end

Given /I have entered (\d+)/ do |n|
  @calc.push n.to_i
end

steps_for(:old_skool_works_too) do
  When 'I add' do
    @result = @calc.add
  end
end

When 'I divide' do
  @result = @calc.divide
end

Then /the result should be (\d*)/ do |result|
  @result.should == result.to_i
end
