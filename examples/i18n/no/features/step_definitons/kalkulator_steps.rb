# encoding: utf-8

Cucumber.alias_steps %w{Gitt Naar Saa}

require 'spec/expectations'
$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'cucumber/formatters/unicode'
require 'kalkulator'

Before do
  @calc = Kalkulator.new
end

After do
end

Gitt /at jeg har tastet inn (\d+)/ do |n|
  @calc.push n.to_i
end

Naar 'jeg summerer' do
  @result = @calc.add
end

Saa /skal resultatet være (\d*)/ do |result|
  @result.should == result.to_i
end
