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

Given /aku sudah masukkan (.*) ke kalkulator/ do |n|
  @calc.push n.to_i
end

When /aku tekan (.*)/ do |op|
  @result = @calc.send op
end

Then /hasilnya harus (.*) di layar/ do |result|
  @result.should == result.to_f
end
