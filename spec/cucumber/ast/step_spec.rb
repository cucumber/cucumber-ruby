require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/step_mother'
require 'cucumber/ast'
require 'cucumber/core_ext/string'

module Cucumber
  module Ast
    describe StepMom do
      it "should calculate comment padding" do
        scenario = Scenario.new(comment=nil, tags=nil, keyword=nil, name=nil, step_names_and_multiline_args=[
          ["Given", "tøtal 13"],
          ["And",   "the total 15"]
        ])
        step1, step2 = *scenario.instance_variable_get('@steps')

        step1.comment_padding.should == 2
        step2.comment_padding.should == 0
      end
    end
    
    describe Step do
      describe "execute step with arguments" do
      
        it "should replace arguments in multiline args" do
          mock_multiline_arg = mock('multiline arg')
          step = Step.new(mock('scenario'), nil, 'Given', '<test>', mock_multiline_arg)

          mock_multiline_arg.should_receive(:arguments_replaced).and_return(mock_multiline_arg)
        
          step.execute_with_arguments({'test' => '10'}, stub('world'), :passed, visitor=nil)
        end
       
        it "should invoke step with replaced multiline args" do
          mock_step_invocation = mock('step invocation')
          mock_multiline_arg_replaced = mock('multiline arg replaced')
          mock_multiline_arg = mock('multiline arg', :arguments_replaced => mock_multiline_arg_replaced)
          step = Step.new(mock('scenario', :step_invocation => mock_step_invocation), nil, 'Given', '<test>', mock_multiline_arg)
          
#          mock_step_invocation.should_receive(:invoke).with(mock_multiline_arg_replaced)
        
          step.execute_with_arguments({'test' => '10'}, stub('world'), :passed, visitor=nil)
        end
  
      end
    end
  end
end
