# encoding: utf-8
require 'spec/expectations'
require 'cucumber/formatter/unicode'
$:.unshift(File.dirname(__FILE__) + '/../../lib') 
require 'calculator'

Before do
  @calc = Calculator.new
end

After do
end

Zadato /Unesen (\d+) broj u kalkulator/ do |n|
  @calc.push n.to_i
end

Kada /pritisnem (\w+)/ do |op|
  @result = @calc.send op
end

Onda /bi trebalo da bude (.*) prikazano na ekranu/ do |result|
  @result.should == result.to_f
end
