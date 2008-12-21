require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/step_mom'
require 'cucumber/ast'
require 'cucumber/core_ext/string'

module Cucumber
  module Ast
    describe Step do
      before do
        @step_mother = mock('StepMother')
        @step = Step.new(@step_mother, false, "Given", "hi var1 yo var2")
        @visitor = mock('Visitor')
      end

      it "should not highlight parameters when it is pending" do
        @step_mother.should_receive(:execute_step_by_name).and_raise(StepMom::Pending.new)
        @visitor.should_receive(:visit_step_name).with("Given", "hi var1 yo var2", :pending)
        @step.accept(@visitor, Object.new)
      end

      it "should highlight parameters when it has passed" do
        @step_mother.should_receive(:execute_step_by_name)
        @visitor.should_receive(:visit_step_name).with("Given", "hi var1 yo var2", :passed)
        @step.accept(@visitor, Object.new)
      end

      it "should highlight parameters when it has failed" do
        @step_mother.should_receive(:execute_step_by_name).and_raise(e=Exception.new)

        @visitor.should_receive(:visit_step_name).with("Given", "hi var1 yo var2", :failed)
        @visitor.should_receive(:visit_step_error).with(e)
        @step.accept(@visitor, Object.new)
      end

      it "should pass inline arguments to step mother and visitor" do
        @step = Step.new(@step_mother, false, "Given", "hi var1 yo var2", table=Table.new([['x']]))

        world = Object.new
        @step_mother.should_receive(:execute_step_by_name).with("hi var1 yo var2", world, table)
        @visitor.should_receive(:visit_step_name).with("Given", "hi var1 yo var2", :passed)
        @visitor.should_receive(:visit_inline_arg).with(table)
        @step.accept(@visitor, world)
      end
    end
  end
end
