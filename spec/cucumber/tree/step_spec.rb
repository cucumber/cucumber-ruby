require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module Tree
    describe Step do
      it "should have padding_length 2 when alone" do
        scenario = Scenario.new(nil, nil, 1)
        step = scenario.create_step('Given', '666666', 98)
        step.padding_length.should == 2
      end

      it "should have padding_length 5 when 3 shorter" do
        scenario = Scenario.new(nil, nil, 1)
        long = scenario.create_step('Given', '999999999', 80)
        step = scenario.create_step('Given', '666666', 98)
        step.padding_length.should == 5
      end
      
      it "should remove indent from padding_length if padding to scenario" do
        scenario = Scenario.new(nil, '9', 1)
        step = scenario.create_step('Given', '9', 80)

        #Scenario: 9  #
        #  Given 9****
        step.padding_length.should == 4
      end

      it "should default step arity to 0" do
        scenario = Scenario.new(nil, '9', 1)
        step = scenario.create_step('Given', '9', 80)
        
        step.arity.should == 0
      end

      describe "utf-8 strings" do

        it "should have padding_length 6 when 4 shorter" do
          scenario = Scenario.new(nil, nil, 1)
          long = scenario.create_step('Given', '999999999', 2)
          step = scenario.create_step('Given', "こんばんは", 3)
        
          step.padding_length.should == 6
        end

      end

      it "should indicate if a forced pending exception occured" do
        scenario = Scenario.new(nil, '9', 1)
        step = scenario.create_step('Given', '666666', 98)
        
        step.instance_variable_set("@error", ForcedPending.new)
        
        step.should be_forced_to_pending
      end
      
    end
  end
end

