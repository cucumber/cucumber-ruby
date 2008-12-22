require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/step_mom'
require 'cucumber/ast'
require 'cucumber/core_ext/string'

module Cucumber
  module Ast
    describe StepMom do
      xit "should pass inline arguments to step mother and visitor" do
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
