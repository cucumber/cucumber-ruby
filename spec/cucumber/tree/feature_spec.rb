require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module Tree
    describe Feature do
      
      it "should have padding_length 2 when alone" do
        feature = Feature.new('header')
        feature.padding_length.should == 2
      end
      
      describe "creating a Scenario" do
      
        it "should create a new scenario for a feature" do
          feature = Feature.new('header')

          Scenario.should_receive(:new).with(feature, 'test scenario', "19")

          feature.Scenario('test scenario') {}
        end
      
      end
      
      describe "creating a Table" do
    
        it "should set the table header of the template scenario" do
          feature = Feature.new('header')
          mock_scenario = mock("scenario", :update_table_column_widths => nil)
          Scenario.stub!(:new).and_return(mock_scenario)
          feature.add_scenario('scenario', 5)    

          mock_scenario.should_receive(:table_header=).with(["input_1", "input_2"])

          feature.Table do |t| 
            t | "input_1" | "input_2" | t 
            t | 1 | 2 | t
          end
        end
      
      end
    end
  end
end
