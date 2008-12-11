require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module Tree
    describe Feature do
      
      def mock_scenario(stubs = {})
        mock("scenario", {:update_table_column_widths => nil,
                          :outline? => false,
                          :table_header= => nil}.merge(stubs))
      end
      
      def mock_scenario_outline(stubs = {})
        mock_scenario({:outline? => true, :row? => false, :table_header= => nil}.merge(stubs))
      end
      
      it "should have padding_length 2 when alone" do
        feature = Feature.new('header')
        feature.padding_length.should == 2
      end
      
      describe "creating a Scenario" do
      
        it "should create a new scenario for a feature" do
          feature = Feature.new('header')

          Scenario.should_receive(:new).with(feature, 'test scenario', "29")

          feature.Scenario('test scenario') {}
        end
      
      end
      
      describe "creating a Scenario Outline" do

        it "should create a new scenario outline for feature" do
          feature = Feature.new('header')
          
          ScenarioOutline.should_receive(:new).with(feature, 'test', '41')
          
          feature.ScenarioOutline('test') {}
        end

      end
      
      describe "creating a Table" do

        before(:each) do
          @feature = Feature.new('header')
        end

        describe "previous scenario is a scenario outline" do

          it "should create a row scenario outline for feature" do
            mock_scenario_outline = mock_scenario_outline(:outline? => true)
            Scenario.stub!(:new).and_return(mock_scenario_outline)
            @feature.add_scenario('scenario', 5)    

            RowScenarioOutline.should_receive(:new).with(@feature, mock_scenario_outline, ['1', '2'], anything)

            @feature.Table do |t| 
              t | "input_1" | "input_2" | t 
              t | 1 | 2 | t
            end
          end

        end
        
        describe "previous scenario was a regular scenario" do
          
          it "should create a row scenario for feature" do
            mock_scenario = mock_scenario(:outline? => false)
            Scenario.stub!(:new).and_return(mock_scenario)
            @feature.add_scenario('scenario', 5)    

            RowScenario.should_receive(:new).with(@feature, mock_scenario, ['1', '2'], anything)

            @feature.Table do |t| 
              t | "input_1" | "input_2" | t 
              t | 1 | 2 | t
            end
          end
          
        end
    
        it "should set the table header of the template scenario" do
          mock_scenario = mock("scenario", :update_table_column_widths => nil, :outline? => false)
          Scenario.stub!(:new).and_return(mock_scenario)
          @feature.add_scenario('scenario', 5)    

          mock_scenario.should_receive(:table_header=).with(["input_1", "input_2"])

          @feature.Table do |t| 
            t | "input_1" | "input_2" | t 
            t | 1 | 2 | t
          end
        end
      
      end
      
      it "should create a new row scenario outline" do
        feature = Feature.new('header')
         
        RowScenarioOutline.should_receive(:new)
           
        feature.add_row_scenario_outline(mock_scenario_outline, [], 1)
      end
      
      it "should visit scenario outline" do
        feature = Feature.new('header')
        ScenarioOutline.stub!(:new).and_return(mock_scenario_outline(:outline? => true, :row? => false))
        feature.add_scenario_outline(nil, nil)
        mock_visitor = mock('visitor', :visit_header => nil)

        mock_visitor.should_receive(:visit_scenario_outline)
        
        feature.accept(mock_visitor)
      end
            
    end
  end
end
