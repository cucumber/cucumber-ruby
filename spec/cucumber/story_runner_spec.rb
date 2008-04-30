require File.dirname(__FILE__) + '/../spec_helper'
require 'stringio'
require 'cucumber/progress_formatter'

module Cucumber
  describe StoryRunner do
    before do
      @io = StringIO.new
      f = ProgressFormatter.new(@io)
      @r = StoryRunner.new(f)
      @story_file = File.dirname(__FILE__) + '/sell_cucumbers.story'
      @r.load(@story_file)
    end

    it "should pass when blocks are ok" do
      o = Object.new
      @r.register_proc(/there are (\d*) cucumbers/)     { |n| @n = n }
      @r.register_proc(/I sell (\d*) cucumbers/)        { |n| @n = n }
      @r.register_proc(/I should owe (\d*) cucumbers/) { |n| @n = n }
      @r.run
      @io.string.should == "...\n"
    end

    it "should print filtered backtrace with story line" do
      o = Object.new
      @r.register_proc(/there are (\d*) cucumbers/)     { |n| @n = n }
      @r.register_proc(/I sell (\d*) cucumbers/)        { |n| @n = n }
      @r.register_proc(/I should owe (\d*) cucumbers/) { |n| raise "dang" }
      @r.run
      @io.string.should == <<-STDOUT
..F

1)
dang
#{__FILE__}:28:in `Then /I should owe (\\d*) cucumbers/'
#{@story_file}:9:in `Then I should owe 7 cucumbers'
STDOUT
    end
  end
end
