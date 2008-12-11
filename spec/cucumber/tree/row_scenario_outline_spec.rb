require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module Tree
    describe RowScenarioOutline do

      def mock_feature
         mock_feature = mock("feature")
      end

      def mock_scenario(stubs ={})
        mock("scenario", {:update_table_column_widths => nil}.merge(stubs))
      end

      def mock_step(stubs = {})
        mock("step", {:arity => 0}.merge(stubs))
      end

      it "should indicate scenario is a scenario outline" do
        outline = RowScenarioOutline.new(mock_feature, mock_scenario, [], 1)
      
        outline.should be_a_outline
      end
  
      describe "steps" do

        it "should create a new step with placeholders in template scenario steps replaced with values from scenario row" do
          mock_step = mock_step(:keyword => 'Given', :name => '<animal> burning bright')
          mock_scenario = mock_scenario(:table_header => ["animal"], :steps => [mock_step] )
          outline = RowScenarioOutline.new(mock_feature, mock_scenario, ["tiger"], 1)

          RowStepOutline.should_receive(:new).with(outline, mock_step, 'tiger burning bright', ["tiger"], 1)

          outline.steps
        end
      
        it "should leave the scenario template's name unchanged when replacing placeholders" do
          mock_step = mock_step(:keyword => 'Given', :name => '<animal> burning bright', :extra_args => [])
          mock_scenario = mock_scenario(:table_header => ["animal"], :steps => [mock_step] )
          outline = RowScenarioOutline.new(mock_feature, mock_scenario, ["tiger"], 1)

          outline.steps
          
          mock_step.name.should == '<animal> burning bright'
        end

        it "should leave the step name untouched if it has no placeholders" do
          mock_step = mock_step(:keyword => 'Given', :name => 'beauty too rich for earth too dear')
          mock_scenario = mock_scenario(:table_header => ["animal"], :steps => [mock_step] )     
          outline = RowScenarioOutline.new(mock_feature, mock_scenario, ["tiger"], 1)

          RowStepOutline.should_receive(:new).with(outline, mock_step, 'beauty too rich for earth too dear', [], 1)

          outline.steps
        end
            
        it "should ensure that created steps do not contain values already used in previous steps" do
          mock_step_1 = mock_step(:keyword => 'Given', :name => '<animal> eating')
          mock_step_2 = mock_step(:keyword => 'Given', :name => 'eating <animal>')
          mock_scenario = mock_scenario(:table_header => ["animal"], :steps => [mock_step_1, mock_step_2] )       
          outline = RowScenarioOutline.new(mock_feature, mock_scenario, ["tiger"], 1)
                                                                                              
          RowStepOutline.should_receive(:new).with(anything, anything, anything, ['tiger'], anything)
          RowStepOutline.should_receive(:new).with(anything, anything, anything, [], anything)

          outline.steps
        end
            
      end
      
    end
  end
end
