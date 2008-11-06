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

      it "should include indent when padding to step" do
        scenario = Scenario.new(nil, '', 1)
        scenario.create_step('Given', 'a long step', 1)

        #Scenario: *********
        #  Given a long step
        scenario.padding_length.should == 9 + Scenario::INDENT
      end

      it "should ignore step padding if scenario is longer than all steps" do
        scenario = Scenario.new(nil, 'Very long scenario and then some', 1)
        scenario.create_step('Given', 'test', 1)

        scenario.padding_length.should == 2
      end

      describe "utf-8 strings" do
        describe "when calculating padding" do

          it "should take into consideration utf-8 scenario names" do
            scenario = Scenario.new(nil, 'こんばんは', 1)
            scenario.create_step('Given', 'a long step', 1)
        
            #Scenario: こんばんは****
            #  Given a long step
            scenario.padding_length.should == 4 + Scenario::INDENT
          end
      
          it "should take into consideration a utf-8 keyword for 'scenario'" do
            Cucumber.language.stub!(:[]).with('scenario').and_return("シナリオ")
            scenario = Scenario.new(nil, '', 1)
            scenario.create_step('Given', 'step', 1)
        
            #シナリオ: ******
            #  Given step
            scenario.padding_length.should == 6 + Scenario::INDENT
          end
        
        end
      end
      
      describe "pending?" do
        before :each do
          @scenario = Scenario.new(nil, '', 1)
        end
        
        it "should return true if there aren't any steps" do
          @scenario.should be_pending
        end
        
        it "should return false if there are steps" do
          @scenario.create_step('Given', 'a long step', 1)
          @scenario.should_not be_pending
        end
      end
    end
  end
end
