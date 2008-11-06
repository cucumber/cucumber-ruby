require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module Tree
    describe RowScenario do
      
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
    end
  end
end
