require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/step_mom'
require 'cucumber/ast'
require 'cucumber/core_ext/string'

module Cucumber
  module Ast
    describe ScenarioOutline do
      # Scenario Outline: reusing place holder
      #   Given there are <start> cucumbers
      #   When I eat <eat> cucumbers
      #   Then I should have <left> cucumbers
      #   And I should have <eat> cucumbers in my belly
      # 
      # Examples:
      #   | start  | eat  | left |
      #   |  12    |  5   |  7   |
      #   |  20    |  6   |  14  |
      it "should reuse variables" do
        step_mother = mock("StepMother")

        scenario_outline = ScenarioOutline.new(
          Comment.new(""),
          Tags.new([]),
          "My outline",
          [
            Step.new(step_mother, 'Given', 'there are <start> cucumbers'),
            Step.new(step_mother, 'When',  'I eat <eat> cucumbers'),
            Step.new(step_mother, 'Then',  'I should have <left> cucumbers'),
            Step.new(step_mother, 'And',   'I should have <eat> cucumbers in my belly')
          ],
          [
            %w{start eat left},
            %w{12 5 7},
            %w{20 6 14}
          ]
        )

        step_mother.should_receive(:execute_step_by_name).with("there are 12 cucumbers", anything)
        step_mother.should_receive(:execute_step_by_name).with("I eat 5 cucumbers", anything)
        step_mother.should_receive(:execute_step_by_name).with("I should have 7 cucumbers", anything)
        step_mother.should_receive(:execute_step_by_name).with("I should have 5 cucumbers in my belly", anything)

        step_mother.should_receive(:execute_step_by_name).with("there are 20 cucumbers", anything)
        step_mother.should_receive(:execute_step_by_name).with("I eat 6 cucumbers", anything)
        step_mother.should_receive(:execute_step_by_name).with("I should have 14 cucumbers", anything)
        step_mother.should_receive(:execute_step_by_name).with("I should have 6 cucumbers in my belly", anything)

        if ENV['CUCUMBER_DEBUG']
          require 'cucumber/formatter/pretty'
          mom = Object.new
          mom.extend(StepMom)
          visitor = Formatter::Pretty.new(mom, STDOUT)
          visitor.visit_feature_element(scenario_outline)
        else
          visitor = Visitor.new
          visitor.visit_feature_element(scenario_outline)
        end
      end
    end
  end
end
