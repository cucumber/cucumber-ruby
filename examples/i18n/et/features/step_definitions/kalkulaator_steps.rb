require 'spec'
$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'cucumber/formatters/unicode'
require 'kalkulaator'

Before do
  @calc = Kalkulaator.new
end

After do
end

Given /olen sisestanud kalkulaatorisse numbri (\d+)/ do |n|
  @calc.push n.to_i
end

When /ma vajutan (.*)/ do |op|
  @result = @calc.send op
end

Then /vastuseks peab ekraanil kuvatama (\d*)/ do |result|
  @result.should == result.to_i
end

Then /vastuseklass peab olema tüüpi (\w*)/ do |class_name|
  @result.class.name.should == class_name
end