require 'rubygems'
require 'spec'
require File.dirname(__FILE__) + '/../spec/spec_helper'
#require 'stories/steps/cucumber_steps'
# TODO: Make this happen in stories/steps - can happen with require cucumber/standalone

mother = Cucumber::StepMother.new
mother.step('there are $n cucumbers') do |n|
  puts "there are"
end
mother.step('I sell $n cucumbers') do |n|
  puts "I sell"
end
mother.step('there should be $n cucumbers left') do |n|
  puts "there should be"
end


parser = Cucumber::StoryParser.new
story = parser.parse(IO.read('stories/sell_cucumbers.story'))

class Printer
  def story(name)
    puts "STORY: #{name}"
  end

  def narrative(name)
    puts "NARRATIVE: #{name}"
  end

  def scenario(name)
    puts "SCENARIO: #{name}"
  end

  def step(step_type, name, line)
    puts "STEP: #{line}: #{step_type}: #{name}"
  end
end

story.eval(Printer.new)
