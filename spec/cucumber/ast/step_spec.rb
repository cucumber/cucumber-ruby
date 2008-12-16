require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/ast/step'
require 'cucumber/core_ext/string'

module Cucumber
  module Ast
    describe Step do
      before do
        @formats = {
          :passed_param   => lambda{|p| "[#{p}]"},
          :passed         => lambda{|s| "[[#{s}]]"},
          :failed_param   => "<%s>",
          :failed         => "<<%s>>",
          :pending        => "??%s??"
        }
        @step = Step.new("Given", "hi var1 yo var2")
        @world = Object.new
      end
      
      it "should not highlight parameters when it is pending" do
        @step.format(@formats).should == "??Given hi var1 yo var2??"
      end

      it "should highlight parameters when it has passed" do
        step_def = mock('StepDef')
        step_def.should_receive(:execute_in)
        step_def.should_receive(:regexp).and_return(/hi (.*) yo (.*)/)
        @step.step_def = step_def
        @step.execute_in(@world)
        @step.format(@formats).should == "[[Given hi [var1] yo [var2]]]"
      end

      it "should highlight parameters when it has failed" do
        step_def = mock('StepDef')
        step_def.should_receive(:execute_in).and_raise(e=Exception.new)
        step_def.should_receive(:regexp).and_return(/hi (.*) yo (.*)/)
        step_def.should_receive(:strip_backtrace!).with(e, anything)
        @step.step_def = step_def
        @step.execute_in(@world)
        @step.format(@formats).should == "<<Given hi <var1> yo <var2>>>"
      end
      
      it "should execute with plain variables" do
        @step.step_def = StepDefinition.new(/hi (.*) yo (.*)/) { |var1, var2|
          var1.should == "nope"
        }
        @step.execute_in(@world)
        @step.error.message.should =~ /expected: "nope"/
      end

      it "should execute within world" do
        @step.step_def = StepDefinition.new(/hi (.*) yo (.*)/) { |var1, var2|
          @world_var = 'hello'
        }
        @step.execute_in(@world)
        @world.instance_variable_get('@world_var').should == 'hello'
      end
    end
  end
end
