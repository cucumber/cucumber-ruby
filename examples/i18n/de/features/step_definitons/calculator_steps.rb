require 'spec'
$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'cucumber/formatters/unicode'
require 'calculator'

Before do
  @calc = Calculator.new
end

After do
end

Given "ich habe $n in den Taschenrechner eingegeben" do |n|
  @calc.push n.to_i
end

When /ich (\w+) drücke/ do |op|
  @result = @calc.send op
end

Then /sollte das Ergebniss auf dem Bildschirm (.*) sein/ do |result|
  @result.should == result.to_f
end

Then /die Ergebnissklasse sollte eine (\w*) sein/ do |class_name|
  @result.class.name.should == class_name
end

Given /it should rain on (\w+)/ do |day|
  @calc.rain?(day).should == true
end
