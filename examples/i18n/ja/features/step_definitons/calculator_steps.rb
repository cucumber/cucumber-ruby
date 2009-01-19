# encoding: utf-8
require 'spec/expectations'
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
