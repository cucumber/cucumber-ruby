# encoding: Shift_JIS
require 'spec/expectations'
$:.unshift(File.dirname(__FILE__) + '/../../lib') # This line is not needed in your own project
require 'cucumber/formatters/unicode'
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
