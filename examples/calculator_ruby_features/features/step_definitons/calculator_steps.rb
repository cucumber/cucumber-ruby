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

Given /I have entered (\d+) into the calculator/ do |n|
  @calc.push n.to_i
end

When 'I add' do
  @result = @calc.add
end

When 'I divide' do
  @result = @calc.divide
end

Then /the result should be (\d*) on the screen/ do |result|
  @result.should == result.to_i
end

Then /the result class should be (\w*)/ do |class_name|
  @result.class.name.should == class_name
end
