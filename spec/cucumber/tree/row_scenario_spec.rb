require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module Tree
    describe RowScenario do
      
      def mock_scenario(stubs = {})
        mock('scenario', {:update_table_column_widths => nil, :steps => []}.merge(stubs))
      end
            
      describe "pending?" do
        before :each do
          @scenario = Scenario.new(nil, '', 1)
          @row_scenario = RowScenario.new(mock('feature'), @scenario, [], 1)
        end
        
        it "should return true if the template scenario has no steps" do
          @row_scenario.should be_pending
        end
        
        it "should return false if the template scenario has no steps" do
          @scenario.create_step('Given', 'a long step', 1)
          @row_scenario.should_not be_pending
        end
      end
            
      describe "generating row steps" do
        
         it "should cache unbound steps" do
          row_scenario = RowScenario.new(mock('feature'), mock_scenario, [], 1)        
          
          row_scenario.steps.should equal(row_scenario.steps)
        end
        
        it "should cache bound steps" do
          mock_step = mock('step', :arity => 1)
          row_scenario = RowScenario.new(mock('feature'), mock_scenario(:steps => [mock_step]), [], 1)        
          
          row_scenario.steps.should equal(row_scenario.steps)
        end
        
        it "should regenerate row steps when scenario template steps have been matched" do
          mock_step = mock('step', :arity => 0)
          row_scenario = RowScenario.new(mock('feature'), mock_scenario(:steps => [mock_step]), [], 1)        
          unbound_steps = row_scenario.steps
          mock_step.stub!(:arity => 1)
          
          unbound_steps.should_not equal(row_scenario.steps)
        end

      end
          
    end
  end
end
