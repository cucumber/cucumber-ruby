require File.dirname(__FILE__) + '/../spec_helper'
require 'stringio'

module Cucumber
  describe Executor do
    
    def mock_scenario(stubs = {})
      @scenario ||= stub("scenario", {
        :row? => false, 
        :name => 'test', 
        :accept => nil, 
        :steps => [],
        :pending? => true,
        :outline? => false,
      }.merge(stubs))
    end
    
    def parse_features(feature_file)
      parser = TreetopParser::FeatureParser.new
      feature = parser.parse_feature(feature_file)
    end

    before do
      ::Term::ANSIColor.coloring = false
    end

    after do
      ::Term::ANSIColor.coloring = true
    end

    before do # TODO: Way more setup and duplication of lib code. Use lib code!
      @io = StringIO.new
      @step_mother = StepMother.new
      @executor = Executor.new(@step_mother)
      @formatters = Broadcaster.new [Formatters::ProgressFormatter.new(@io)]
      @executor.formatters = @formatters
      @feature_file = File.dirname(__FILE__) + '/sell_cucumbers.feature'
      @features = features = Tree::Features.new
      @feature = parse_features(@feature_file)
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
#{__FILE__}:56:in `Then /I should owe (\\d*) cucumbers/'
#{@feature_file}:9:in `Then I should owe 7 cucumbers'
})
    end

    describe "creating a world" do
      module DoitExtension
        def doit
          "dunit"
        end
      end

      module BeatitExtension
        def beatit
          "beatenit"
        end
      end
      
      it "should yield an Object to the world proc" do
        @executor.register_world_proc do |world|
          world.extend(DoitExtension)
        end
        @executor.register_world_proc do |world|
          world.extend(BeatitExtension)
        end
        world = @executor.create_world
        world.doit.should == "dunit"
        world.beatit.should == "beatenit"
      end
      
      it "should add support for calling 'pending' from world" do
        world = @executor.create_world
      
        world.should respond_to(:pending)
      end
      
    end

    describe "visiting feature" do

      it "should set the feature file being visited" do
        mock_feature = mock('feature', :file => 'womble.feature', :scenarios => [])
        @executor.visit_feature(mock_feature)
    
        @executor.instance_variable_get('@feature_file').should == 'womble.feature'
      end

    end

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
    
    describe "visiting step outline" do
        
      it "should trace step" do
        mock_formatter = mock('formatter')
        @executor.formatters = mock_formatter
        mock_step_outline = mock('step outline', :regexp_args_proc => [])
 
        mock_formatter.should_receive(:step_traced)
        
        @executor.visit_step_outline(mock_step_outline)
      end
      
    end
    
    describe "visit forced pending step" do

      before(:each) do
        @executor.formatters = mock('formatter', :null_object => true)          
      end

      it "should store the pending exception with the step" do
        mock_step = mock("mock step", :regexp_args_proc => nil)
        pending_exception = ForcedPending.new("implement me")
        mock_step.stub!(:execute_in).and_raise(pending_exception)

        mock_step.should_receive(:'error=').with(pending_exception)
        
        @executor.visit_step(mock_step)
      end
      
      describe "after failed/pending step" do
        
        it "should store the pending exception with the step" do
          mock_step_1 = mock("mock step", :null_object => true)
          mock_step_2 = mock("mock step", :regexp_args_proc => nil)
          pending_exception = ForcedPending.new("implement me")
          mock_step_1.stub!(:execute_in).and_raise(StandardError)
          mock_step_2.stub!(:execute_in).and_raise(pending_exception)

          mock_step_2.should_receive(:'error=').with(pending_exception)

          @executor.visit_step(mock_step_1)
          @executor.visit_step(mock_step_2)
        end
        
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

      %w{regular_scenario scenario_outline}.each do |regular_or_outline|

        before(:each) do
          @scenario = mock("#{regular_or_outline} scenario", :name => 'test', :at_line? => true, :pending? => false, :accept => nil)

          @executor.lines_for_features = Hash.new([5])
          @executor.send("visit_#{regular_or_outline}".to_sym, @scenario)
        end

        describe "without having first run the matching #{regular_or_outline}" do
        
            it "should run the #{regular_or_outline} before the row scenario" do
              @scenario.should_receive(:accept)
              row_scenario = mock_row_scenario(:name => 'test', :at_line? => true)
              row_scenario.should_receive(:accept)

              @executor.visit_row_scenario(row_scenario)
            end

            it "should run the row scenario after running the #{regular_or_outline}" do
              row_scenario = mock_row_scenario(:at_line? => true)
              row_scenario.should_receive(:accept)
              @scenario.stub!(:accept)

              @executor.visit_row_scenario(row_scenario)
            end
      
        end

        describe "having run matching #{regular_or_outline}" do
      
          it "should not run the regular scenario if it has already run" do
            @scenario.should_not_receive(:accept)

            @executor.visit_row_scenario(mock_row_scenario(:name => 'test', :at_line? => true, :accept => nil))
          end
      
        end
      end
    end
    
    describe "visiting scenarios" do
      
      it "should check if a scenario is at the specified line number" do
        mock_scenario = mock('scenario', :null_object => true)
        @executor.lines_for_features = Hash.new([1])

        mock_scenario.should_receive(:at_line?).with(1)

        @executor.visit_scenario(mock_scenario)
      end
    
     describe "with specific features and lines" do

        it "should check if a scenario is at the specified feature line number" do
          @executor.instance_variable_set('@feature_file', 'sell_cucumbers.feature')
          @executor.lines_for_features = {'sell_cucumbers.feature' => [11]}

          mock_scenario.should_receive(:at_line?).with(11).and_return(false)

          @executor.visit_scenario(mock_scenario)
        end

        it "should not check feature line numbers if --line is already set" do
          @executor.instance_variable_set('@feature_file', 'sell_cucumbers.feature')
          @executor.lines_for_features = {'sell_cucumbers.feature' => [11]}
          @executor.lines_for_features = Hash.new([5])

          mock_scenario.should_not_receive(:at_line?).with(11).and_return(false)

          @executor.visit_scenario(mock_scenario)
        end

        it "should not check feature line numbers if the current feature file does not have lines specified" do
          @executor.instance_variable_set('@feature_file', 'beetlejuice.feature')
          @executor.lines_for_features = {'sell_cucumbers.feature' => [11]}

          mock_scenario.should_not_receive(:at_line?).with(11).and_return(false)

          @executor.visit_scenario(mock_scenario)
        end

      end
    
    end
    
    describe "caching visited scenarios" do
 
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
