# encoding: UTF-8
require 'spec/expectations'
$:.unshift(File.dirname(__FILE__) + '/../../lib') # This line is not needed in your own project
require 'cucumber/formatter/unicode'
require 'calculator'

Before do
  @calc = Calculator.new
end

After do
end

前提 "$n を入力" do |n|
  @calc.push n.to_i
end

もし /(\w+) を押した/ do |op|
  @result = @calc.send op
end

ならば /(.*) を表示/ do |result|
  @result.should == result.to_f
end
