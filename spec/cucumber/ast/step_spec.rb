require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/ast/step'
require 'cucumber/core_ext/string'

module Cucumber
  module Ast
    describe Step do
      before do
        @formats = {
          :passed_param   => @passed_param = lambda{|p| "[#{p}]"},
          :passed         => @passed = lambda{|s| "[[#{s}]]"},
          :failed_param   => "<%s>",
          :failed         => "<<%s>>",
          :pending        => "??%s??"
        }
        @step_mother = mock('StepMother')
        @step = Step.new(@step_mother, "Given", "hi var1 yo var2")
        @world = Object.new
      end
      
      it "should not highlight parameters when it is pending" do
        @step.format(@formats).should == "??Given hi var1 yo var2??"
      end

      it "should highlight parameters when it has passed" do
        @step_mother.should_receive(:execute_step_definition)
        @step_mother.should_receive(:format).with("hi var1 yo var2", @passed_param).and_return("hi [var1] yo [var2]")
        @step.execute_in(@world)
        @step.format(@formats).should == "[[Given hi [var1] yo [var2]]]"
      end

      it "should highlight parameters when it has failed" do
        @step_mother.should_receive(:execute_step_definition).and_raise(e=Exception.new)
        @step_mother.should_receive(:format).with("hi var1 yo var2", "<%s>").and_return("hi <var1> yo <var2>")
        @step.execute_in(@world)
        @step.format(@formats).should == "<<Given hi <var1> yo <var2>>>"
      end
    end
  end
end
