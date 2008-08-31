require 'spec'
$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'calculator'

Before do
  @calc = Calculator.new
end

After do
end

Given "I have entered $n into the calculator" do |n|
  @calc.push n.to_i
end

When /I press (\w+)/ do |op|
  @result = @calc.send op
end

Then /the result should be (.*) on the screen/ do |result|
  @result.should == result.to_f
end

Then /the result class should be (\w*)/ do |class_name|
  @result.class.name.should == class_name
end

Given /it should rain on (\w+)/ do |day|
  @calc.rain?(day).should == true
end

