# encoding: utf-8
require 'spec/expectations'
$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'cucumber/formatters/unicode'
require 'calculator'

Before do
  @calc = Calculator.new
end

After do
end

Given /ich habe (.*) in den Taschenrechner eingegeben/ do |n|
  @calc.push n.to_i
end

When /ich (.*) drücke/ do |op|
  @result = @calc.send op
end

Then /sollte das Ergebniss auf dem Bildschirm (.*) sein/ do |result|
  @result.should == result.to_f
end
