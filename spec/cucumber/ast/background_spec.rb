require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/ast'

module Cucumber
  module Ast
    describe Background do

      it "should visit a step on the first background run" do
        step = Step.new(7, "Given", "passing")
        background = Background.new(
          comment=Comment.new(""), 
          line=99,
          keyword="", 
          steps=[
            step
          ])
          visitor = mock('visitor', :null_object => true)

          visitor.should_receive(:visit_step).with(step)
          
          background.accept(visitor)
      end
      
      describe "having already visited background once" do

        before(:each) do
          @mock_step = mock('step', :null_object => true, :text_length => 1)
          @background = Background.new(
            comment=Comment.new(""), 
            line=99,
            keyword="", 
            steps=[
              @mock_step
            ])
            
          @visitor = mock('visitor', :null_object => true)
          @background.accept(@visitor)
        end
      
        it "should execute the steps" do
          @mock_step.should_receive(:execute_as_new).and_return(mock('executed step', :null_object => true))
        
          @background.accept(@visitor)
        end
        
        it "should visit the background if there was a exception when executing a step" do
          mock_executed_step = mock('executed step', :null_object => true, :exception => Exception.new)
          @mock_step.stub!(:execute_as_new).and_return(mock_executed_step)
        
          @visitor.should_receive(:visit_background).with(@background)
        
          @background.accept(@visitor)
        end

      end
    end
  end
end
