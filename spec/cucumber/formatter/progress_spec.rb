require 'spec_helper'
require 'cucumber/formatter/progress'
require 'cucumber/formatter/spec_helper'
require 'cucumber/cli/options'

module Cucumber
  module Formatter
    describe Progress do
      extend SpecHelperDsl
      include SpecHelper

      before(:each) do
        Cucumber::Term::ANSIColor.coloring = false
        @out = StringIO.new
        @formatter = Progress.new(step_mother, @out, {})
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

          it "outputs the undefined step" do
            expect(@out.string).to include "U\n"
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

          it "outputs the two undefined steps" do
            expect(@out.string).to include "UU\n"
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

          it "outputs each undefined step" do
            expect(@out.string).to include "UUUU\n"
          end

          it "has 4 undefined scenarios" do
            expect(@out.string).to include "4 scenarios (4 undefined)"
          end

          it "has 4 undefined steps" do
            expect(@out.string).to include "4 steps (4 undefined)"
          end

        end
      end
    end
  end
end
