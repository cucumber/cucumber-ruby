require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/ast'

module Cucumber
  module Ast
    describe Background do

      before do
        @step_mother = Object.new
        @step_mother.extend(StepMother)
        $x = $y = nil
        @step_mother.Before do
          $x = 2
        end
        @step_mother.Given /y is (\d+)/ do |n|
          $y = $x * n.to_i
        end
        @visitor = Visitor.new(@step_mother)
        @visitor.options = {}

        @feature = mock('feature', :visit? => true).as_null_object
      end

      it "should execute Before blocks before background steps" do
        background = Background.new(
          comment=Comment.new(''),
          line=2,
          keyword="", 
          steps=[
            Step.new(7, "Given", "y is 5")
          ])

        scenario = Scenario.new(
          background,
          comment=Comment.new(""), 
          tags=Tags.new(98,[]),
          line=99,
          keyword="", 
          name="", 
          steps=[])
        background.feature = @feature
        
        @visitor.visit_background(background)
        $x.should == 2
        $y.should == 10
      end
    end
  end
end
