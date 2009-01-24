require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/step_mother'
require 'cucumber/ast'
require 'cucumber/core_ext/string'

module Cucumber
  module Ast
    describe StepMother do
      it "should calculate comment padding" do
        scenario = Scenario.new(comment=nil, tags=nil, line=nil, keyword='Given', name='Gazpacho', steps=[
          Step.new(22, "Given", "tøtal 13"),
          Step.new(23, "And",   "the total 15")
        ])
        step1, step2 = *scenario.instance_variable_get('@steps')

        step1.source_indent.should == 2
        step2.source_indent.should == 0
      end
    end
    
    describe Step do
      describe "execute step with arguments" do
      
        it "should replace arguments in multiline args" do
          mock_multiline_arg = mock('multiline arg')
          step = Step.new(23, 'Given', '<test>', mock_multiline_arg)

          mock_multiline_arg.should_receive(:arguments_replaced).with({'<test>' => '10'}).and_return(mock_multiline_arg)
        
          step.execute_with_arguments({'test' => '10'}, stub('world'), :passed, visitor=nil, line=-1)
        end
       
        it "should invoke step with replaced multiline args" do
          mock_step_definition = mock('step definition')
          mock_multiline_arg_replaced = mock('multiline arg replaced')
          mock_multiline_arg = mock('multiline arg', :arguments_replaced => mock_multiline_arg_replaced)
          step = Step.new(45, 'Given', '<test>', mock_multiline_arg)
        
          step.execute_with_arguments({'test' => '10'}, stub('world'), :passed, visitor=nil, line=-1)
        end
  
      end
    end
  end
end
