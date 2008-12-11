require 'spec'
$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'cucumber/formatters/unicode'
require 'calculator'

Before do
  @calc = Calculator.new
end

After do
end

Given "كتابة $n في الآلة الحاسبة" do |n|
  @calc.push n.to_i
end

When /يتم الضغط على (\w+)/ do |op|
  @result = @calc.send op
end

Then /يظهر (.*) على الشاشة/ do |result|
  @result.should == result.to_f
end

Then /يجب ان يكون (\w*)/ do |class_name|
  @result.class.name.should == class_name
end

Given /it should rain on (\w+)/ do |day|
  @calc.rain?(day).should == true
end

