require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/step_mom'
require 'cucumber/ast'
require 'cucumber/core_ext/string'

module Cucumber
  module Ast
    describe ScenarioOutline do
      it "should execute outline steps when row matches 1 step" do
        step_mother = mock("StepMother")

        scenario_outline = ScenarioOutline.new(
          Comment.new(""),
          Tags.new([]),
          "My outline",
          [
            Step.new(step_mother, 'Given', 'a <color> <veggie>')
          ],
          [
            %w{green cucumber},
            %w{red tomato}
          ]
        )
        
        step_mother.should_receive(:execute_step_by_name).with("a green cucumber", anything)
        step_mother.should_receive(:execute_step_by_name).with("a red tomato", anything)
        visitor = Visitor.new
        scenario_outline.accept(visitor)

        # Just keeping this code for debugging (output)
        #
        # require 'cucumber/formatter/pretty'
        # mom = Object.new
        # mom.extend(StepMom)
        # visitor = Formatter::Pretty.new(mom, STDOUT)
        # visitor.visit_feature_element(scenario_outline)
      end

      it "should execute outline steps when row matches 2 steps" do
        step_mother = mock("StepMother")

        scenario_outline = ScenarioOutline.new(
          Comment.new(""),
          Tags.new([]),
          "My outline",
          [
            Step.new(step_mother, 'Given', 'a <color> glove'),
            Step.new(step_mother, 'Given', 'a tasty <veggie>')
          ],
          [
            %w{green cucumber},
            %w{red tomato}
          ]
        )

        step_mother.should_receive(:execute_step_by_name).with("a green glove", anything)
        step_mother.should_receive(:execute_step_by_name).with("a tasty cucumber", anything)
        step_mother.should_receive(:execute_step_by_name).with("a red glove", anything)
        step_mother.should_receive(:execute_step_by_name).with("a tasty tomato", anything)
        visitor = Visitor.new
        scenario_outline.accept(visitor)
      end
    end
  end
end
