require 'spec'
$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'calculatrice'

Before do
  @calc = Calulatrice.new
end

After do
end

Given /que j'ai entré (\d+)/ do |n|
  @calc.push n.to_i
end

When 'je tape additionner' do
  @result = @calc.additionner
end

Then /le reultat doit être (\d*)/ do |result|
  @result.should == result.to_i
end
