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
      end
      
      it "should not highlight parameters when it is pending" do
        step = Step.new("Given", "hi var1 yo var2")
        step.format(@formats).should == "??Given hi var1 yo var2??"
      end

      it "should highlight parameters when it has passed" do
        step = Step.new("Given", "hi var1 yo var2")
        step_def = mock('StepDef')
        step_def.should_receive(:execute)
        step_def.should_receive(:regexp).and_return(/hi (.*) yo (.*)/)
        step.step_def = step_def
        step.execute
        step.format(@formats).should == "[[Given hi [var1] yo [var2]]]"
      end

      it "should highlight parameters when it has failed" do
        step = Step.new("Given", "hi var1 yo var2")
        step_def = mock('StepDef')
        step_def.should_receive(:execute).and_raise(Exception.new)
        step_def.should_receive(:regexp).and_return(/hi (.*) yo (.*)/)
        step.step_def = step_def
        step.execute
        step.format(@formats).should == "<<Given hi <var1> yo <var2>>>"
      end
    end
  end
end
