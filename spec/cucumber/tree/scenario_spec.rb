require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module Tree
    describe Scenario do      
      xit "should reuse steps in GivenScenario" do
        given_scenario = GivenScenario.new(scenario_2, "First", 99)
      
        scenario_2.create_step(given_scenario)
        scenario_2.create_step(step_a)
        scenario_2.steps.should == [step_1, step_2, step_a]
      end
      
      it "should have padding_length 2 when alone" do
        scenario = Scenario.new(nil, 'test', 1)
        scenario.padding_length.should == 2
      end
      
      it "should have padding matching largest step padding" do
        scenario = Scenario.new(nil, '', 1)
        scenario.create_step('Given', 'a long step', 1)

        # Scenario: ***********
        #   Given a long step
        scenario.padding_length.should == 9 + 2 #Allow for indent
      end
  
      it "should use scenario padding if bigger than all steps" do
        scenario = Scenario.new(nil, 'Very long scenario and then some', 1)
        scenario.create_step('Given', 'test', 1)
        
        scenario.padding_length.should == 2                                                                                                                                     
      end
      
    end
  end
end
