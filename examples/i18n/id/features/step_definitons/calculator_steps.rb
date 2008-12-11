require 'spec'
$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'cucumber/formatters/unicode'
require 'calculator'

Before do
  @calc = Calculator.new
end

After do
end

Given "aku sudah masukkan $n ke kalkulator" do |n|
  @calc.push n.to_i
end

When /aku tekan (\w+)/ do |op|
  @result = @calc.send op
end

Then /hasilnya harus (.*) di layar/ do |result|
  @result.should == result.to_f
end

Then /class hasilnya harus (\w*)/ do |class_name|
  @result.class.name.should == class_name
end

Given /it should rain on (\w+)/ do |day|
  @calc.rain?(day).should == true
end

