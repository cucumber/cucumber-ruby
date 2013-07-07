require 'spec_helper'
require 'cucumber/step_mother'
require 'cucumber/ast'
require 'cucumber/core_ext/string'
require 'cucumber/rb_support/rb_language'

module Cucumber
  module Ast
    describe ScenarioOutline do
      before do
        @step_mother = Cucumber::Runtime.new
        @step_mother.load_programming_language('rb')
        @dsl = Object.new
        @dsl.extend(Cucumber::RbSupport::RbDsl)

        @dsl.Given(/^there are (\d+) cucumbers$/) do |n|
          @initial = n.to_i
        end
        @dsl.When(/^I eat (\d+) cucumbers$/) do |n|
          @eaten = n.to_i
        end
        @dsl.Then(/^I should have (\d+) cucumbers$/) do |n|
          (@initial - @eaten).should == n.to_i
        end
        @dsl.Then(/^I should have (\d+) cucumbers in my belly$/) do |n|
          @eaten.should == n.to_i
        end

        location = Ast::Location.new('foo.feature', 19)
        language = double

        @scenario_outline = ScenarioOutline.new(
          language,
          location,
          background=Ast::EmptyBackground.new,
          Comment.new(""),
          Tags.new(18, []),
          Tags.new(0, []),
          "Scenario:", "My outline", "",
          [
            Step.new(language, location.on_line(20), 'Given', 'there are <start> cucumbers'),
            Step.new(language, location.on_line(21), 'When',  'I eat <eat> cucumbers'),
            Step.new(language, location.on_line(22), 'Then',  'I should have <left> cucumbers'),
            Step.new(language, location.on_line(23), 'And',   'I should have <eat> cucumbers in my belly')
          ],
          [
            [
              [
                location.on_line(24),
                Comment.new("#Mmmm... cucumbers\n"),
                'Examples:',
                'First table',
                '',
                [
                  %w{start eat left},
                  %w{12 5 7},
                  %w{20 6 14}
                ]
              ],
              Gherkin::Formatter::Model::Examples.new(nil, nil, nil, nil, nil, nil, nil, nil)
            ]
          ]
        )
      end

      it "should replace all variables and call outline once for each table row" do
        visitor = TreeWalker.new(@step_mother)
        visitor.should_receive(:visit_table_row).exactly(3).times
        @scenario_outline.feature = double.as_null_object
        visitor.visit_feature_element(@scenario_outline)
      end
    end
  end
end
