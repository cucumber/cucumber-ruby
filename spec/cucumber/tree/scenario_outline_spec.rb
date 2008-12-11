require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module Tree
    describe ScenarioOutline do

      def mock_feature
         mock_feature = mock("feature")
      end

      def mock_scenario(stubs ={})
        mock("scenario", {:update_table_column_widths => nil}.merge(stubs))
      end

      it "should indicate its a scenario outline" do
        scenario_outline = ScenarioOutline.new(mock_feature, '', 1)
        
        scenario_outline.should be_a_outline 
      end
      
      it "should create a step outline when adding new steps" do
        scenario_outline = ScenarioOutline.new(mock_feature, '', 1)
        
        StepOutline.should_receive(:new)
        
        scenario_outline.create_step('Given', '', 2)
      end
      
      it "should visit step outlines" do
        outline = ScenarioOutline.new(mock_feature, '', 1)
        outline.create_step('Given', '', 1)
        mock_visitor = mock('visitor')        
        
        mock_visitor.should_receive(:visit_step_outline)
        
        outline.accept(mock_visitor)
      end

      it "should include indent when padding to step" do
        scenario = ScenarioOutline.new(mock_feature, '', 1)
        scenario.create_step('Given', 'a longish step', 1)

        #Scenario Outline: ****
        #  Given a longish step
        scenario.padding_length.should == 4 + Scenario::INDENT
      end
      
    end
  end
end
