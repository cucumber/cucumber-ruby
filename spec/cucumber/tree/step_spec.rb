require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module Tree
    describe Step do
      it "should have padding_length 2 when alone" do
        scenario = Scenario.new(nil, nil)
        step = scenario.create_step('Given', '666666', 98)
        step.padding_length.should == 2
      end

      it "should have padding_length 5 when 3 shorter" do
        scenario = Scenario.new(nil, nil)
        long = scenario.create_step('Given', '999999999', 80)
        step = scenario.create_step('Given', '666666', 98)
        step.padding_length.should == 5
      end
    end
  end
end

