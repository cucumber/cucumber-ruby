require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/step_mother'
require 'cucumber/ast'

module Cucumber
  module Ast
    describe Scenario do
      before do
        @step_mother = Object.new
        @step_mother.extend(StepMother)
        $x = $y = nil
        @step_mother.Given /y is (\d+)/ do |n|
          $y = n.to_i
        end
        @visitor = Visitor.new(@step_mother)
        @visitor.options = {}
      end

      it "should skip steps when previous is not passed" do
        scenario = Scenario.new(
          background=nil,
          comment=Comment.new(""),
          tags=Tags.new(98, []), 
          line=99,
          keyword="",
          name="", 
          steps=[
            Step.new(7, "Given", "this is missing"),
            Step.new(8, "Given", "y is 5")
          ])
        @visitor.visit_feature_element(scenario)

        $y.should == nil
      end

      it "should be at exact line" do
        s = Scenario.new(background=nil, comment=Comment.new(""), 
          tags=Tags.new(44, []), 45, keyword="", name="", steps=[])

        s.should be_matches_lines([44])
        s.should be_matches_lines([45])
      end

      it "should be at line if tags or steps are" do
        s = Scenario.new(
          background=nil,
          comment=Comment.new(""), 
          tags=Tags.new(43, []), 
          line=45,
          keyword="",
          name="", 
          steps=[
            Step.new(46, "Given", ""),
            Step.new(47, "Given", ""),
            Step.new(48, "Given", ""),
          ]
        )

        s.should be_matches_lines([43])
        s.should be_matches_lines([47])
        s.should_not be_matches_lines([49])
      end
    end
  end
end
