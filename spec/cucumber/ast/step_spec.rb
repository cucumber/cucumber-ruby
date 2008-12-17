require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/step_mom'
require 'cucumber/ast'
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
        @step.world = Object.new
        @visitor = mock('Visitor')
      end

      it "should not highlight parameters when it is pending" do
        @step_mother.should_receive(:execute_step_definition).and_raise(StepMom::Pending.new)
        @visitor.should_receive(:visit_step_name).with("??Given hi var1 yo var2??")
        @step.accept(@visitor, @formats)
      end

      it "should highlight parameters when it has passed" do
        @step_mother.should_receive(:execute_step_definition)
        @step_mother.should_receive(:format).with("hi var1 yo var2", @passed_param).and_return("hi [var1] yo [var2]")
        @visitor.should_receive(:visit_step_name).with("[[Given hi [var1] yo [var2]]]")
        @step.accept(@visitor, @formats)
      end

      it "should highlight parameters when it has failed" do
        @step_mother.should_receive(:execute_step_definition).and_raise(e=Exception.new)
        @step_mother.should_receive(:format).with("hi var1 yo var2", "<%s>").and_return("hi <var1> yo <var2>")

        @visitor.should_receive(:visit_step_name).with("<<Given hi <var1> yo <var2>>>")
        @visitor.should_receive(:visit_step_error).with(e)
        @step.accept(@visitor, @formats)
      end

      it "should pass inline arguments to step mother" do
        @step = Step.new(@step_mother, "Given", "hi var1 yo var2", table=Table.new([['x']]))
        @step.world = world = Object.new

        @step_mother.should_receive(:execute_step_definition).with("hi var1 yo var2", world, table)
        @step_mother.should_receive(:format).with("hi var1 yo var2", @passed_param).and_return("hi [var1] yo [var2]")
        @visitor.should_receive(:visit_step_name).with("[[Given hi [var1] yo [var2]]]")
        @visitor.should_receive(:visit_inline_arg).with(table)
        @step.accept(@visitor, @formats)
      end
    end
  end
end
