# encoding: utf-8
require 'spec/expectations'
$:.unshift(File.dirname(__FILE__) + '/../../lib') # This line is not needed in your own project
require 'cucumber/formatters/unicode'
require 'kalkulator'

# Not necessary with Ruby 1.9 - Gitt, Når Så automatically aliased.
Cucumber.alias_steps %w{Naar Saa}

Before do
  @calc = Kalkulator.new
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
