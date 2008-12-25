require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/step_mom'
require 'cucumber/ast'
require 'cucumber/core_ext/string'

module Cucumber
  module Ast
    describe StepMom do
      it "should calculate comment padding" do
        scenario = Scenario.new(step_mother=nil, comment=nil, tags=nil, name=nil, step_names_and_multiline_args=[
          ["Given", "tøtal 13"],
          ["And",   "the total 15"]
        ])
        step1, step2 = *scenario.instance_variable_get('@steps')

        step1.comment_padding.should == 2
        step2.comment_padding.should == 0
      end
    end
  end
end
