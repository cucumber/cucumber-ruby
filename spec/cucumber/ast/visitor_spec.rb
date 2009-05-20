require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/step_mother'
require 'cucumber/ast'

module Cucumber
  module Ast
    describe Visitor do
      
      it "should support checking scenario name matches regexps" do
        visitor = Visitor.new(mock("step mother"))
        scenario = Scenario.new(background=nil,
          comment=Comment.new(""),
          tags=Tags.new(0, []), 
          line=99,
          keyword="",
          name="test name", 
          steps=[])

        visitor.options = {:name_regexps => [/name/]}
        
        visitor.matches_scenario_names?(scenario).should be_true
      end
      
    end
  end
end

