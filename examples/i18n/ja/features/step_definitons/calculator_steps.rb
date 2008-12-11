require 'spec'
$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'cucumber/formatters/unicode'
$KCODE = 'e'
require 'calculator'

Before do
  @calc = Calculator.new
end

After do
end

Given "$n を入力" do |n|
  @calc.push n.to_i
end

When /(\w+) ボタンを押した/ do |op|
  @result = @calc.send op
end

Then /結果は (.*) を表示/ do |result|
  @result.should == result.to_f
end

Then /結果のクラスは (\w*)/ do |class_name|
  @result.class.name.should == class_name
end

Given /it should rain on (\w+)/ do |day|
  @calc.rain?(day).should == true
end
