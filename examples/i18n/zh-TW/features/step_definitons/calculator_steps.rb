# encoding: utf-8
require 'spec/expectations'
$:.unshift(File.dirname(__FILE__) + '/../../lib') # This line is not needed in your own project
require 'cucumber/formatters/unicode'
require 'calculator'

Before do
  @calc = Calculator.new
end

After do
end

Given /我已經在計算器上輸入了 (\d+)/ do |n|
  @calc.push n.to_i
end

When /我按下 (\w+)/ do |op|
  @result = @calc.send op
end

Then /計算器應該顯示 (.*)/ do |result|
  @result.should == result.to_f
end
