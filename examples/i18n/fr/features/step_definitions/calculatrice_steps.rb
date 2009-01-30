# encoding: utf-8
require 'spec/expectations'
$:.unshift(File.dirname(__FILE__) + '/../../lib') # This line is not needed in your own project
require 'cucumber/formatters/unicode'
require 'calculatrice'

Before do
  @calc = Calulatrice.new
end

After do
end

# Etant donné que je tape ...
Given /que je tape (\d+)/ do |n|
  @calc.push n.to_i
end

# Lorsque je tape additionner
When 'je tape additionner' do
  @result = @calc.additionner
end

# Alors le résultat doit être ...
Then /le résultat doit être (\d*)/ do |result|
  @result.should == result.to_i
end
