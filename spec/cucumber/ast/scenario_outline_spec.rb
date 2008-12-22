require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/step_mom'
require 'cucumber/ast'
require 'cucumber/core_ext/string'

module Cucumber
  module Ast
    describe ScenarioOutline do
      def make_scenario_outline(step_mother)
        scenario_outline = ScenarioOutline.new(
          step_mother,
          Comment.new(""),
          Tags.new([]),
          "My outline",
          [
            ['Given', 'there are <start> cucumbers'],
            ['When',  'I eat <eat> cucumbers'],
            ['Then',  'I should have <left> cucumbers'],
            ['And',   'I should have <eat> cucumbers in my belly']
          ],
          [
            %w{start eat left},
            %w{12 5 7},
            %w{20 6 14}
          ]
        )
      end

      it "should replace all variables and call outline once for each table row" do
        step_mother = mock("StepMother")
        step_mother.should_receive(:new_world!).exactly(2).times.and_return(Object.new)
        scenario_outline = make_scenario_outline(step_mother)

        visitor = Visitor.new
        invocation = mock('Invocation')
        invocation.stub!(:invoke)

        visitor.should_receive(:visit_step_name).with('Given', 'there are <start> cucumbers', :outline, nil, 12)
        visitor.should_receive(:visit_step_name).with('When',  'I eat <eat> cucumbers', :outline, nil, 19)
        visitor.should_receive(:visit_step_name).with('Then',  'I should have <left> cucumbers', :outline, nil, 10)
        visitor.should_receive(:visit_step_name).with('And',   'I should have <eat> cucumbers in my belly', :outline, nil, 0)

        step_mother.should_receive(:invocation).with("there are 12 cucumbers").and_return(invocation)
        step_mother.should_receive(:invocation).with("I eat 5 cucumbers").and_return(invocation)
        step_mother.should_receive(:invocation).with("I should have 7 cucumbers").and_return(invocation)
        step_mother.should_receive(:invocation).with("I should have 5 cucumbers in my belly").and_return(invocation)

        step_mother.should_receive(:invocation).with("there are 20 cucumbers").and_return(invocation)
        step_mother.should_receive(:invocation).with("I eat 6 cucumbers").and_return(invocation)
        step_mother.should_receive(:invocation).with("I should have 14 cucumbers").and_return(invocation)
        step_mother.should_receive(:invocation).with("I should have 6 cucumbers in my belly").and_return(invocation)

        visitor.visit_feature_element(scenario_outline)
      end

      xit "should pretty print" do
        require 'cucumber/formatter/pretty'
        step_mother = Object.new
        step_mother.extend(StepMom)
        scenario_outline = make_scenario_outline(step_mother)
        visitor = Formatter::Pretty.new(step_mother, STDOUT)
        visitor.visit_feature_element(scenario_outline)
      end
    end
  end
end
