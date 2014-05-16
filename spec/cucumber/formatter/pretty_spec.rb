require 'spec_helper'
require 'cucumber/formatter/spec_helper'
require 'cucumber/formatter/pretty'
require 'cucumber/cli/options'

module Cucumber
  module Formatter
    describe Pretty do
      extend SpecHelperDsl
      include SpecHelper

      context "With no options" do
        before(:each) do
          Cucumber::Term::ANSIColor.coloring = false
          @out = StringIO.new
          @formatter = Pretty.new(runtime, @out, {})
        end

        describe "given a single feature" do
          before(:each) do
            run_defined_feature
          end

          describe "with a scenario" do
            define_feature <<-FEATURE
          Feature: Banana party

            Scenario: Monkey eats banana
              Given there are bananas
            FEATURE

            it "outputs the scenario name" do
              expect(@out.string).to include "Scenario: Monkey eats banana"
            end

            it "outputs the step" do
              expect(@out.string).to include "Given there are bananas"
            end
          end

          describe "with a background" do
            define_feature <<-FEATURE
Feature: Banana party

  Background: 
    Given a tree

  Scenario: Monkey eats banana
    Given there are bananas
            FEATURE

            it "outputs the gherkin" do
              expect(@out.string).to include(self.class.feature_content)
            end

            it "outputs the scenario name" do
              expect(@out.string).to include "Scenario: Monkey eats banana"
            end

            it "outputs the step" do
              expect(@out.string).to include "Given there are bananas"
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

            it "outputs the scenario outline" do
              lines = <<-OUTPUT
              Examples: Fruit
               | Things  |
               | apples  |
               | bananas |
              Examples: Vegetables
               | Things   |
               | broccoli |
               | carrots  |
              OUTPUT
              lines.split("\n").each do |line|
                expect(@out.string).to include line.strip
              end
            end

            it "has 4 undefined scenarios" do
              expect(@out.string).to include "4 scenarios (4 undefined)"
            end

            it "has 4 undefined steps" do
              expect(@out.string).to include "4 steps (4 undefined)"
            end

            context 'when the examples table header is wider than the rows' do
              define_feature <<-FEATURE
          Feature: Monkey Business

            Scenario Outline: Types of monkey
              Given there are <Types of monkey>

              Examples:
               | Types of monkey |
               | Hominidae       |
              FEATURE

              it "outputs the scenario outline" do
                lines = <<-OUTPUT
              Examples:
               | Types of monkey |
               | Hominidae       |
                OUTPUT
                lines.split("\n").each do |line|
                  expect(@out.string).to include line.strip
                end
              end
            end
          end

          # To ensure https://rspec.lighthouseapp.com/projects/16211/tickets/475 remains fixed.
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

            it "outputs the scenario outline" do
              lines = <<-OUTPUT
              Given a multiline string:
                """
                Monkeys eat <things>
                """

              Examples:
               | things |
               | apples |
              OUTPUT
              lines.split("\n").each do |line|
                expect(@out.string).to include line.strip
              end
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

            it "displays the pystring nested" do
              expect(@out.string).to include <<OUTPUT
      """
      foo
      """
OUTPUT
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

            it "displays the multiline string" do
              expect(@out.string).to include <<OUTPUT
    Given there are monkeys:
      | name |
      | foo  |
      | bar  |
OUTPUT
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
              expect(@out.string).to include <<OUTPUT
    Given table:
      | a | b |
      | c | d |
OUTPUT
            end

            it "displays the table for the scenario" do
              expect(@out.string).to include <<OUTPUT
    Given another table:
      | e | f |
      | g | h |
OUTPUT
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
              expect(@out.string).to include <<OUTPUT
    Given stuff:
      """
      foo
      """
OUTPUT
            end

            it "displays the scenario py string" do
              expect(@out.string).to include <<OUTPUT
    Given more stuff:
      """
      bar
      """
OUTPUT
            end
          end
        end
      end

      context "With --no-multiline passed as an option" do
        before(:each) do
          Cucumber::Term::ANSIColor.coloring = false
          @out = StringIO.new
          @formatter = Pretty.new(runtime, @out, {:no_multiline => true})
        end

        describe "given a single feature" do
          before(:each) do
            run_defined_feature
          end

          describe "with a scenario" do
            define_feature <<-FEATURE
          Feature: Banana party

            Scenario: Monkey eats banana
              Given there are bananas
            FEATURE

            it "outputs the scenario name" do
              expect(@out.string).to include "Scenario: Monkey eats banana"
            end

            it "outputs the step" do
              expect(@out.string).to include "Given there are bananas"
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

            it "outputs the scenario outline" do
              lines = <<-OUTPUT
              Examples: Fruit
               | Things  |
               | apples  |
               | bananas |
              Examples: Vegetables
               | Things   |
               | broccoli |
               | carrots  |
              OUTPUT
              lines.split("\n").each do |line|
                expect(@out.string).to include line.strip
              end
            end

            it "has 4 undefined scenarios" do
              expect(@out.string).to include "4 scenarios (4 undefined)"
            end

            it "has 4 undefined steps" do
              expect(@out.string).to include "4 steps (4 undefined)"
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

            it "does not display the pystring" do
              expect(@out.string).not_to include <<OUTPUT
      """
      foo
      """
OUTPUT
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

            it "does not display the multiline string" do
              expect(@out.string).not_to include <<OUTPUT
      | name |
      | foo  |
      | bar  |
OUTPUT
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

            it "does not display the table for the background" do
              expect(@out.string).not_to include <<OUTPUT
      | a | b |
      | c | d |
OUTPUT
            end
            it "does not display the table for the scenario" do
              expect(@out.string).not_to include <<OUTPUT
      | e | f |
      | g | h |
OUTPUT
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

            it "does not display the background py string" do
              expect(@out.string).not_to include <<OUTPUT
      """
      foo
      """
OUTPUT
            end
            it "does not display the scenario py string" do
              expect(@out.string).not_to include <<OUTPUT
      """
      bar
      """
OUTPUT
            end
          end
        end
      end
    end
  end
end
