require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/step_mom'
require 'cucumber/ast'

module Cucumber
  module Ast
    describe Scenario do
      before do
        @step_mother = Object.new
        @step_mother.extend(StepMom)
        $x = $y = nil
        @step_mother.Before do
          $x = 3
        end
        @step_mother.Given /y is (\d+)/ do |n|
          $y = n.to_i
        end
        @visitor = Visitor.new
      end

      it "should execute Before blocks before steps" do
        scenario = Scenario.new(@step_mother, comment=Comment.new(""), 
          tags=Tags.new([]), name="", step_names_and_multiline_args=[
          ["Given", "y is 5"]
        ])
        @visitor.visit_feature_element(scenario)
        $x.should == 3
        $y.should == 5
      end
    end
  end
end
