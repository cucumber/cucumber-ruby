require 'spec'
$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'cucumber/formatters/unicode'
require 'calculator'

Before do
  @calc = Calculator.new
end

After do
end

Given "aš įvedžiau $n į skaičiuotuvą" do |n|
  @calc.push n.to_i
end

When /aš paspaudžiu "(\w+)"/ do |op|
  @result = @calc.send op
end

Then /rezultatas ekrane turi būti (.*)/ do |result|
  @result.should == result.to_f
end

Then /rezultato klasė turi būti "(\w*)"/ do |class_name|
  @result.class.name.should == class_name
end

Given /turi lyti (\w+)/ do |day|
  @calc.rain?(day).should == true
end

