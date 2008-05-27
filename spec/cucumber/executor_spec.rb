require File.dirname(__FILE__) + '/../spec_helper'
require 'stringio'
require 'cucumber/progress_formatter'

module Cucumber
  describe Executor do
    before do # TODO: Way more setup and duplication of lib code. Use lib code!
      @io = StringIO.new
      @f = ProgressFormatter.new(@io)
      @r = Executor.new(@f)
      @story_file = File.dirname(__FILE__) + '/sell_cucumbers.story'
      parser = Parser::StoryParser.new
      @story = parser.parse(IO.read(@story_file))
      @story.file = @story_file
    end

    it "should pass when blocks are ok" do
      @r.register_step_proc(/there are (\d*) cucumbers/)     { |n| @n = n.to_i }
      @r.register_step_proc(/I sell (\d*) cucumbers/)        { |n| @n -= n.to_i }
      @r.register_step_proc(/I should owe (\d*) cucumbers/)  { |n| @n.should == -n.to_i }
      @story.accept(@r)
      @f.dump
      @io.string.should == "...\n"
    end

    it "should print filtered backtrace with story line" do
      @r.register_step_proc(/there are (\d*) cucumbers/)     { |n| @n = n }
      @r.register_step_proc(/I sell (\d*) cucumbers/)        { |n| @n = n }
      @r.register_step_proc(/I should owe (\d*) cucumbers/) { |n| raise "dang" }
      @story.accept(@r)
      @f.dump
      @io.string.should == <<-STDOUT
..F

1)
dang
#{__FILE__}:29:in `Then /I should owe (\\d*) cucumbers/'
#{@story_file}:9:in `Then I should owe 7 cucumbers'
STDOUT
    end
  end
end
