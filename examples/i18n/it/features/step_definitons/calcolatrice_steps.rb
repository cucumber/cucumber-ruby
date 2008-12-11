require 'spec'
$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'cucumber/formatters/unicode'
require 'calcolatrice'

Before do
  @calc = Calcolatrice.new
end

After do
end

Given /che ho inserito (\d+)/ do |n|
  @calc.push n.to_i
end

When 'premo somma' do
  @result = @calc.add
end

Then /il risultato deve essere (\d*)/ do |result|
  @result.should == result.to_i
end
