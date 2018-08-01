begin
  require 'rspec/expectations'
rescue LoadError
  require 'spec/expectations'
end

require 'cucumber/formatter/unicode'
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'calculator'

Before do
  @calc = Calculator.new
end

After do
end

Given(/mi entajpas (\d+) en la kalkulilon/) do |n|
  @calc.push n.to_i
end

When(/mi premas (\w+)/) do |op|
  @result = @calc.send op
end

Then(/la rezulto estu (.*)/) do |result|
  @result.should == result.to_f
end
