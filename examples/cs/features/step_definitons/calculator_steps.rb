require 'spec/expectations'
$:.unshift(File.dirname(__FILE__) + '/../../lib') # This line is not needed in your own project
require 'Calculator' # Calculator.dll

Before do
  @calc = Demo::Calculator.new # A .NET class in Calculator.dll
end

Given "I have entered $n into the calculator" do |n|
  @calc.push n.to_i
end

When /I press add/ do
  @result = @calc.Add
end

Then /the result should be (.*) on the screen/ do |result|
  @result.should == result.to_i
end
