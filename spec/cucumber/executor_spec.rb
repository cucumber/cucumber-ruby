require File.dirname(__FILE__) + '/../spec_helper'
require 'stringio'

module Cucumber
  describe Executor do
    before do # TODO: Way more setup and duplication of lib code. Use lib code!
      @io = StringIO.new
      @f = Formatters::ProgressFormatter.new(@io)
      @r = Executor.new(@f)
      @story_file = File.dirname(__FILE__) + '/sell_cucumbers.story'
      @parser = Parser::StoryParser.new
      @story = Parser::StoryNode.parse(@story_file, @parser)
    end

    it "should pass when blocks are ok" do
      @r.register_step_proc(/there are (\d*) cucumbers/)     { |n| @n = n.to_i }
      @r.register_step_proc(/I sell (\d*) cucumbers/)        { |n| @n -= n.to_i }
      @r.register_step_proc(/I should owe (\d*) cucumbers/)  { |n| @n.should == -n.to_i }
      @story.accept(@r)
      @f.dump
      @io.string.should == "\e[32m.\e[0m\e[32m.\e[0m\e[32m.\e[0m\n"
    end

    it "should print filtered backtrace with story line" do
      @r.register_step_proc(/there are (\d*) cucumbers/)     { |n| @n = n }
      @r.register_step_proc(/I sell (\d*) cucumbers/)        { |n| @n = n }
      @r.register_step_proc(/I should owe (\d*) cucumbers/) { |n| raise "dang" }
      @story.accept(@r)
      @f.dump
      @io.string.should == <<-STDOUT
\e[32m.\e[0m\e[32m.\e[0m\e[31mF\e[0m

1)
dang
#{__FILE__}:27:in `Then /I should owe (\\d*) cucumbers/'
#{@story_file}:9:in `Then I should owe 7 cucumbers'
STDOUT
    end

    xit "should allow calling of other steps from steps" do
      @r.register_step_proc("call me please") { @x = 1 }
      @r.register_step_proc("I will call you") { @r.register_step_proc("call me please") }
      @r.register_step_proc(/I should owe (\d*) cucumbers/)  { |n| @n.should == -n.to_i }
      @story.accept(@r)
      @f.dump
      @io.string.should == "...\n"
    end
  end
end
