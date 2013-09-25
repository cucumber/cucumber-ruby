require 'spec_helper'
require 'cucumber/formatter/spec_helper'
require 'cucumber/formatter/debug'
require 'cucumber/cli/options'

module Cucumber
  module Formatter
    describe Debug do
      extend SpecHelperDsl
      include SpecHelper

        before(:each) do
          Cucumber::Term::ANSIColor.coloring = false
          @out = StringIO.new
          @formatter = Debug.new(runtime, @out, {})
        end

        describe "given a single feature" do
          before(:each) { run_defined_feature }

          describe "with a scenario" do
            define_feature <<-FEATURE
          Feature: Banana party

            Scenario: Monkey eats banana
              Given there are bananas
            FEATURE

            it "outputs the events as expected" do
              @out.string.should eq(<<EXPECTED)
before_features
  before_feature
    before_tags
    after_tags
    feature_name
    before_feature_element
      before_tags
      after_tags
      scenario_name
      before_steps
        before_step
          before_step_result
            step_name
          after_step_result
        after_step
      after_steps
    after_feature_element
  after_feature
after_features
EXPECTED
            end
          end

          describe "with a scenario with multiple steps" do
            define_feature <<-FEATURE
          Feature: Banana party

            Scenario:
              Given there are bananas
              And there are berries
            FEATURE

            it "outputs the events as expected" do
              @out.string.should eq(<<EXPECTED)
before_features
  before_feature
    before_tags
    after_tags
    feature_name
    before_feature_element
      before_tags
      after_tags
      scenario_name
      before_steps
        before_step
          before_step_result
            step_name
          after_step_result
        after_step
        before_step
          before_step_result
            step_name
          after_step_result
        after_step
      after_steps
    after_feature_element
  after_feature
after_features
EXPECTED
            end
          end

          describe "with 2 scenarios" do
            define_feature <<-FEATURE
          Feature: Banana party

            Scenario: Monkey eats banana
              Given there are bananas

            Scenario: Monkey is hungry
              Given there are no bananas
            FEATURE

            it "outputs the events as expected" do
              @out.string.should eq(<<EXPECTED)
before_features
  before_feature
    before_tags
    after_tags
    feature_name
    before_feature_element
      before_tags
      after_tags
      scenario_name
      before_steps
        before_step
          before_step_result
            step_name
          after_step_result
        after_step
      after_steps
    after_feature_element
    before_feature_element
      before_tags
      after_tags
      scenario_name
      before_steps
        before_step
          before_step_result
            step_name
          after_step_result
        after_step
      after_steps
    after_feature_element
  after_feature
after_features
EXPECTED
            end
          end

          describe "with a background" do
            define_feature <<-FEATURE
          Feature:

            Background:
              Given there is a tree

            Scenario:
              Given there are bananas
            FEATURE

            it "outputs the events as expected" do
              pending("legacy cucumber fires extra step events") if ENV['USE_LEGACY']
              @out.string.should eq(<<EXPECTED)
before_features
  before_feature
    before_tags
    after_tags
    feature_name
    before_background
      background_name
      before_steps
        before_step
          before_step_result
            step_name
          after_step_result
        after_step
      after_steps
    after_background
    before_feature_element
      before_tags
      after_tags
      scenario_name
      before_steps
        before_step
          before_step_result
            step_name
          after_step_result
        after_step
      after_steps
    after_feature_element
  after_feature
after_features
EXPECTED
            end
          end

          describe "with a scenario outline" do
            define_feature <<-FEATURE
          Feature: Fud Pyramid

            Scenario Outline: Monkey eats a balanced diet
              Given there are <Things>

              Examples: Fruit
               | Things  |
               | apples  |
               | bananas |
              Examples: Vegetables
               | Things   |
               | broccoli |
               | carrots  |
            FEATURE

            it "outputs the events as expected" do
              @out.string.should eq(<<EXPECTED)
before_features
  before_feature
    before_tags
    after_tags
    feature_name
    before_feature_element
      before_tags
      after_tags
      scenario_name
      before_steps
        before_step
          before_step_result
            step_name
          after_step_result
        after_step
      after_steps
      before_examples_array
        before_examples
          examples_name
          before_outline_table
            before_table_row
              before_table_cell
                table_cell_value
              after_table_cell
            after_table_row
            before_table_row
              before_table_cell
                table_cell_value
              after_table_cell
            after_table_row
            before_table_row
              before_table_cell
                table_cell_value
              after_table_cell
            after_table_row
          after_outline_table
        after_examples
        before_examples
          examples_name
          before_outline_table
            before_table_row
              before_table_cell
                table_cell_value
              after_table_cell
            after_table_row
            before_table_row
              before_table_cell
                table_cell_value
              after_table_cell
            after_table_row
            before_table_row
              before_table_cell
                table_cell_value
              after_table_cell
            after_table_row
          after_outline_table
        after_examples
      after_examples_array
    after_feature_element
  after_feature
after_features
EXPECTED
              end
            end

          describe "with a scenario outline with a pystring" do
            define_feature <<-FEATURE
          Feature:
            Scenario Outline: Monkey eats a balanced diet
              Given a multiline string:
                """
                Monkeys eat <things>
                """

              Examples:
               | things |
               | apples |
            FEATURE

            it "outputs the events as expected" do
              @out.string.should eq(<<EXPECTED)
before_features
  before_feature
    before_tags
    after_tags
    feature_name
    before_feature_element
      before_tags
      after_tags
      scenario_name
      before_steps
        before_step
          before_step_result
            step_name
            before_multiline_arg
              doc_string
            after_multiline_arg
          after_step_result
        after_step
      after_steps
      before_examples_array
        before_examples
          examples_name
          before_outline_table
            before_table_row
              before_table_cell
                table_cell_value
              after_table_cell
            after_table_row
            before_table_row
              before_table_cell
                table_cell_value
              after_table_cell
            after_table_row
          after_outline_table
        after_examples
      after_examples_array
    after_feature_element
  after_feature
after_features
EXPECTED
            end
          end

          describe "with a step with a py string" do
            define_feature <<-FEATURE
          Feature: Traveling circus

            Scenario: Monkey goes to town
              Given there is a monkey called:
               """
               foo
               """
            FEATURE

            it "displays the events as expected" do
              @out.string.should eq(<<EXPECTED)
before_features
  before_feature
    before_tags
    after_tags
    feature_name
    before_feature_element
      before_tags
      after_tags
      scenario_name
      before_steps
        before_step
          before_step_result
            step_name
            before_multiline_arg
              doc_string
            after_multiline_arg
          after_step_result
        after_step
      after_steps
    after_feature_element
  after_feature
after_features
EXPECTED
            end
          end

          describe "with a multiline step arg" do
            define_feature <<-FEATURE
          Feature: Traveling circus

            Scenario: Monkey goes to town
              Given there are monkeys:
               | name |
               | foo  |
               | bar  |
            FEATURE

            it "displays the events as expected" do
              @out.string.should eq(<<EXPECTED)
before_features
  before_feature
    before_tags
    after_tags
    feature_name
    before_feature_element
      before_tags
      after_tags
      scenario_name
      before_steps
        before_step
          before_step_result
            step_name
            before_multiline_arg
              before_table_row
                before_table_cell
                  table_cell_value
                after_table_cell
              after_table_row
              before_table_row
                before_table_cell
                  table_cell_value
                after_table_cell
              after_table_row
              before_table_row
                before_table_cell
                  table_cell_value
                after_table_cell
              after_table_row
            after_multiline_arg
          after_step_result
        after_step
      after_steps
    after_feature_element
  after_feature
after_features
EXPECTED
            end
          end

          describe "with a table in the background and the scenario" do
            define_feature <<-FEATURE
          Feature: accountant monkey

            Background:
              Given table:
                | a | b |
                | c | d |
            Scenario:
              Given another table:
               | e | f |
               | g | h |
            FEATURE

            it "displays the table for the background" do
              pending("legacy cucumber fires extra step events") if ENV['USE_LEGACY']
              @out.string.should eq(<<EXPECTED)
before_features
  before_feature
    before_tags
    after_tags
    feature_name
    before_background
      background_name
      before_steps
        before_step
          before_step_result
            step_name
            before_multiline_arg
              before_table_row
                before_table_cell
                  table_cell_value
                after_table_cell
                before_table_cell
                  table_cell_value
                after_table_cell
              after_table_row
              before_table_row
                before_table_cell
                  table_cell_value
                after_table_cell
                before_table_cell
                  table_cell_value
                after_table_cell
              after_table_row
            after_multiline_arg
          after_step_result
        after_step
      after_steps
    after_background
    before_feature_element
      before_tags
      after_tags
      scenario_name
      before_steps
        before_step
          before_step_result
            step_name
            before_multiline_arg
              before_table_row
                before_table_cell
                  table_cell_value
                after_table_cell
                before_table_cell
                  table_cell_value
                after_table_cell
              after_table_row
              before_table_row
                before_table_cell
                  table_cell_value
                after_table_cell
                before_table_cell
                  table_cell_value
                after_table_cell
              after_table_row
            after_multiline_arg
          after_step_result
        after_step
      after_steps
    after_feature_element
  after_feature
after_features
EXPECTED
            end
          end

          describe "with a py string in the background and the scenario" do
            define_feature <<-FEATURE
          Feature: py strings

            Background:
              Given stuff:
                """
                foo
                """
            Scenario:
              Given more stuff:
                """
                bar
                """
            FEATURE

            it "displays the background py string" do
              pending("legacy cucumber fires extra step events") if ENV['USE_LEGACY']
              @out.string.should eq(<<EXPECTED)
before_features
  before_feature
    before_tags
    after_tags
    feature_name
    before_background
      background_name
      before_steps
        before_step
          before_step_result
            step_name
            before_multiline_arg
              doc_string
            after_multiline_arg
          after_step_result
        after_step
      after_steps
    after_background
    before_feature_element
      before_tags
      after_tags
      scenario_name
      before_steps
        before_step
          before_step_result
            step_name
            before_multiline_arg
              doc_string
            after_multiline_arg
          after_step_result
        after_step
      after_steps
    after_feature_element
  after_feature
after_features
EXPECTED
            end

          end
        end
    end
  end
end
