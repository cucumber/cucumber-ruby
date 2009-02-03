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
          comment=Comment.new(""), 
          tags=Tags.new(98,[]),
          line=99,
          keyword="", 
          name="", 
          steps=[])
        background.feature_elements = [scenario]
        background.feature = @feature
        scenario.background = background
        
        @visitor.visit_background(background)
        $x.should == 2
        $y.should == 10
      end

      it "should visit a step on the first background run" do
        step = Step.new(7, "Given", "passing")
        background = Background.new(
          comment=Comment.new(""), 
          line=99,
          keyword="", 
          steps=[
            step
          ])
        background.feature_elements = [mock('scenario').as_null_object]
        background.feature = @feature
        
        @visitor.should_receive(:visit_step).with(step)
          
        background.accept(@visitor)
      end
      
      describe "having already visited background once" do

        before(:each) do
          @mock_step = mock('step', :text_length => 1).as_null_object
          @background = Background.new(
            comment=Comment.new(""), 
            line=99,
            keyword="", 
            steps=[
              @mock_step
            ])
          @background.feature_elements = [mock('scenario').as_null_object]
          @background.feature = @feature

          @background.accept(@visitor)
        end
      
        it "should execute the steps" do
          @mock_step.should_receive(:execute_as_new).and_return(mock('executed step', :exception => nil).as_null_object)

          @background.accept(@visitor)
        end
        
        it "should visit the background if there was a exception when executing a step" do
          pending "We need to hook the failing background into the formatter to get newlines"
          mock_executed_step = mock('executed step', :exception => Exception.new).as_null_object
          @mock_step.stub!(:execute_as_new).and_return(mock_executed_step)
        
          #@visitor.should_receive(:visit_background).with(@background)
        
          @background.accept(@visitor)
        end

      end
    end
  end
end
