require File.dirname(__FILE__) + '/../spec_helper'
require 'stringio'

module Cucumber
  describe Executor do
    before do # TODO: Way more setup and duplication of lib code. Use lib code!
      @io = StringIO.new
      @formatter = Formatters::ProgressFormatter.new(@io)
      @step_mother = StepMother.new
      @executor = Executor.new(@formatter, @step_mother)
      @feature_file = File.dirname(__FILE__) + '/sell_cucumbers.feature'
      @parser = TreetopParser::FeatureParser.new
      @features = Tree::Features.new
      @features << @parser.parse_feature(@feature_file)
    end
    
    it "should pass when blocks are ok" do
      @step_mother.register_step_proc(/there are (\d*) cucumbers/)     { |n| @n = n.to_i }
      @step_mother.register_step_proc(/I sell (\d*) cucumbers/)        { |n| @n -= n.to_i }
      @step_mother.register_step_proc(/I should owe (\d*) cucumbers/)  { |n| @n.should == -n.to_i }
      @executor.visit_features(@features)
      @formatter.dump
      @io.string.should == (<<-STDOUT).strip
\e[0m\e[1m\e[32m.\e[0m\e[0m\e[0m\e[1m\e[32m.\e[0m\e[0m\e[0m\e[1m\e[32m.\e[0m\e[0m\e[0m\e[1m\e[31m\n\e[0m\e[0m\e[1m\e[31m
\e[0m
STDOUT

    end

    it "should print filtered backtrace with feature line" do
      @step_mother.register_step_proc(/there are (\d*) cucumbers/)     { |n| @n = n }
      @step_mother.register_step_proc(/I sell (\d*) cucumbers/)        { |n| @n = n }
      @step_mother.register_step_proc(/I should owe (\d*) cucumbers/) { |n| raise "dang" }
      @executor.visit_features(@features)
      @io.string.should == (<<-STDOUT).strip
\e[0m\e[1m\e[32m.\e[0m\e[0m\e[0m\e[1m\e[32m.\e[0m\e[0m\e[0m\e[1m\e[31mF\e[0m\e[0m\e[0m\e[1m\e[31m

1)
dang
#{__FILE__}:33:in `Then /I should owe (\\d*) cucumbers/'
#{@feature_file}:9:in `Then I should owe 7 cucumbers'
\e[0m
STDOUT
    end

#     it "should allow calling of other steps from steps" do
#       @executor.register_step_proc("call me please") { @x = 1 }
#       @executor.register_step_proc("I will call you") { @executor.register_step_proc("call me please") }
#       @executor.register_step_proc(/I should owe (\d*) cucumbers/)  { |n| @n.should == -n.to_i }
#       @feature.accept(@executor)
#       @formatter.dump
#       @io.string.should == "...\n"
#     end

    describe "visiting steps" do
      def make_regex(a,b,c)
        exp = "#{a}.*#{b}.*#{c}"
        Regexp.compile(exp)
      end

      it "should report multiple definitions as an error" do
        @step_mother.register_step_proc(/there are (\d*) cucumbers/)     {|n|}
        @step_mother.register_step_proc(/there (.*) (\d*) cucumbers/)    {|n|}
        @step_mother.register_step_proc(/I sell (\d*) cucumbers/)        {|n|}
        @executor.visit_features(@features)
        @io.string.should =~ make_regex('F','_','P')
      end
      
      it "should report subsequent multiple definitions as an skipped" do
        @step_mother.register_step_proc(/there are (\d*) cucumbers/)     {|n|}
        @step_mother.register_step_proc(/there (.*) (\d*) cucumbers/)    {|n|}
        @step_mother.register_step_proc(/I sell (\d*) cucumbers/)        {|n|}
        @step_mother.register_step_proc(/I sell (\d*) (.*)/)             {|n|}
        @executor.visit_features(@features)
        @io.string.should =~ make_regex('F','_','P')
      end
      
      it "should report pending steps after failures" do
        @step_mother.register_step_proc(/there are (\d*) cucumbers/)     {|n|}
        @step_mother.register_step_proc(/I sell (\d*) cucumbers/)        {|n| raise "oops"}
        @executor.visit_features(@features)
        @io.string.should =~ make_regex('\.','F','P')
      end
      
      it "should skip passing steps after failures" do
        @step_mother.register_step_proc(/there are (\d*) cucumbers/)     {|n|}
        @step_mother.register_step_proc(/I sell (\d*) cucumbers/)        {|n| raise "oops"}
        @step_mother.register_step_proc(/I should owe (\d*) cucumbers/)  {|n|}
        @executor.visit_features(@features)
        @io.string.should =~ make_regex('\.','F','_')
      end
      
      it "should skip failing steps after failures" do
        @step_mother.register_step_proc(/there are (\d*) cucumbers/)     {|n|}
        @step_mother.register_step_proc(/I sell (\d*) cucumbers/)        {|n| raise "oops"}
        @step_mother.register_step_proc(/I should owe (\d*) cucumbers/)  {|n| raise "oops again"}
        @executor.visit_features(@features)
        @io.string.should =~ make_regex('\.','F','_')
      end
      

      it "should report pending steps after pending" do
        @step_mother.register_step_proc(/I sell (\d*) cucumbers/)        {|n|}
        @executor.visit_features(@features)
        @io.string.should =~ make_regex('P','_','P')
      end
      
      it "should skip passing steps after pending" do
        @step_mother.register_step_proc(/I sell (\d*) cucumbers/)        {|n|}
        @step_mother.register_step_proc(/I should owe (\d*) cucumbers/)  {|n|}
        @executor.visit_features(@features)
        @io.string.should =~ make_regex('P','_','_')
      end
      
      it "should skip failing steps after pending" do
        @step_mother.register_step_proc(/I sell (\d*) cucumbers/)        {|n| raise "oops"}
        @step_mother.register_step_proc(/I should owe (\d*) cucumbers/)  {|n| raise "oops again"}
        @executor.visit_features(@features)
        @io.string.should =~ make_regex('P','_','_')
      end
      
      it "should report an ArityMismatchError" do
        @step_mother.register_step_proc(/there are (\d*) cucumbers/) {}
        @executor.visit_features(@features)
        @io.string.should =~ /expected 0 block argument\(s\), got 1/m
      end
      
    end

  end
end
