require 'rubygems'
require 'spec'
require File.dirname(__FILE__) + '/../spec/spec_helper'
#require 'stories/steps/cucumber_steps'
# TODO: Make this happen in stories/steps - can happen with require cucumber/standalone

mother = Cucumber::StepMother.new
runner = Cucumber::Runner.new

mother.step('there are $n cucumbers') do |n|
  puts "there are"
end
mother.step('I sell $n cucumbers') do |n|
  puts "I sell"
end
mother.step('there should be $n cucumbers left') do |n|
  puts "there should be"
end

runner.load 'stories/sell_cucumbers.story'

print_visitor = Cucumber::Visitors::PrettyPrinter.new
runner.accept(print_visitor)
