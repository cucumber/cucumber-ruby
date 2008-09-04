require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module Tree
    describe Scenario do      
      xit "should reuse steps in GivenScenario" do
        given_scenario = GivenScenario.new(scenario_2, "First", 99)
      
        scenario_2.add_step(given_scenario)
        scenario_2.add_step(step_a)
        scenario_2.steps.should == [step_1, step_2, step_a]
      end
    end
  end
end
