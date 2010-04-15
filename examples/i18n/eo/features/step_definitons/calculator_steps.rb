# encoding: utf-8
require 'spec/expectations' 
require 'cucumber/formatter/unicode'
$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'calculator'

Before do
  @calc = Calculator.new
end

After do
end

Given /mi entajpas (\d+) en kalkulilo/ do |n|
  @calc.push n.to_i
end

When /mi premas (\w+)/ do |op|
  @result = @calc.send op
end

Then /la rezulto devas esti (.*)/ do |result|
  @result.should == result.to_f
end
