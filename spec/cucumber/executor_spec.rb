require File.dirname(__FILE__) + '/../spec_helper'
require 'stringio'

module Cucumber
  describe Executor do
    before do # TODO: Way more setup and duplication of lib code. Use lib code!
      @io = StringIO.new
      @step_mother = StepMother.new
      @executor = Executor.new(@step_mother)
      @formatters = Broadcaster.new [Formatters::ProgressFormatter.new(@io)]
      @executor.formatters = @formatters
      @feature_file = File.dirname(__FILE__) + '/sell_cucumbers.feature'
      @parser = TreetopParser::FeatureParser.new
      @features = Tree::Features.new
      @feature = @parser.parse_feature(@feature_file)
      @features << @feature
    end
    
    it "should pass when blocks are ok" do
      @step_mother.register_step_proc(/there are (\d*) cucumbers/)     { |n| @n = n.to_i }
      @step_mother.register_step_proc(/I sell (\d*) cucumbers/)        { |n| @n -= n.to_i }
      @step_mother.register_step_proc(/I should owe (\d*) cucumbers/)  { |n| @n.should == -n.to_i }
      @executor.visit_features(@features)
      @formatters.dump

      @io.string.should =~ (/\.+\n+/)
    end

    it "should print filtered backtrace with feature line" do
      @step_mother.register_step_proc(/there are (\d*) cucumbers/)     { |n| @n = n }
      @step_mother.register_step_proc(/I sell (\d*) cucumbers/)        { |n| @n = n }
      @step_mother.register_step_proc(/I should owe (\d*) cucumbers/) { |n| raise "dang" }
      @executor.visit_features(@features)
      @io.string.should include(%{Failed:

1)
dang
#{__FILE__}:32:in `Then /I should owe (\\d*) cucumbers/'
#{@feature_file}:9:in `Then I should owe 7 cucumbers'
})
    end

#     it "should allow calling of other steps from steps" do
#       @executor.register_step_proc("call me please") { @x = 1 }
#       @executor.register_step_proc("I will call you") { @executor.register_step_proc("call me please") }
#       @executor.register_step_proc(/I should owe (\d*) cucumbers/)  { |n| @n.should == -n.to_i }
#       @feature.accept(@executor)
#       @formatters.each { |formatter| formatter.dump }
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
              
    describe "visiting row scenarios" do
      
      def mock_row_scenario(stubs = {})
        @row_scenario ||= stub("row scenario", {
          :row? => true, 
          :name => 'test', 
          :update_table_column_widths => nil, 
          :steps => [],
          :pending? => true
        }.merge(stubs))
      end

      describe "without having first run the matching regular scenario" do
      
        before(:each) do
          @scenario = Tree::Scenario.new(nil, 'test', 1)
          @executor.line=5        
          @executor.visit_regular_scenario(@scenario)
        end
        
        it "should run the regular scenario before the row scenario" do
          @scenario.should_receive(:accept)

          @executor.visit_row_scenario(mock_row_scenario(:name => 'test', :at_line? => true, :accept => nil))
        end

        it "should run the row scenario after running the regular scenario" do
          mock_row_scenario(:at_line? => true).should_receive(:accept)

          @executor.visit_row_scenario(mock_row_scenario)
        end
      
      end

      describe "having run matching regular scenario" do
      
        it "should not run the regular scenario if it has already run" do
          scenario = Tree::Scenario.new(nil, 'test', 1)
          @executor.visit_regular_scenario(scenario)

          scenario.should_not_receive(:accept)

          @executor.visit_row_scenario(mock_row_scenario(:name => 'test', :at_line? => true, :accept => nil))
        end
      
      end
    end
    
    describe "caching visited scenarios" do

      def mock_scenario(stubs = {})
        @scenario ||= stub("scenario", {
          :row? => false, 
          :name => 'test', 
          :accept => nil, 
          :steps => [],
          :pending? => true
        }.merge(stubs))
      end
      
      it "should reset cache after each feature visit" do
        Tree::Scenario.stub!(:new).and_return(mock_scenario)

        feature = Tree::Feature.new(nil)
        feature.add_scenario(nil, nil)
            
        @executor.visit_feature(feature)
        
        @executor.instance_variable_get("@regular_scenario_cache").should == {}
        @executor.instance_variable_get("@executed_scenarios").should == {}
      end
                  
    end
    
    describe "with specified scenarios" do
      it "should only visit the specified scenarios" do
        $amounts_sold = []

        @step_mother.register_step_proc(/there are (\d*) cucumbers/) { |n| }
        @step_mother.register_step_proc(/I should owe (\d*) cucumbers/) { |n| }
        @step_mother.register_step_proc(/I sell (\d*) cucumbers/) { |n| $amounts_sold << n.to_i }

        @executor.scenario_names = ["Sell a dozen", "Sell fifty"]
        @executor.visit_features(@features)

        $amounts_sold.should == [12, 50]
      end
      
      it "should only visit features with specified scenarios" do
        @executor.scenario_names = ["Jump up and down"]
        @feature.should_not_receive(:accept).with(@executor)
        @executor.visit_features(@features)
      end
    end
  end
end
