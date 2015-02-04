require 'spec_helper'
require 'cucumber/formatter/spec_helper'
require 'cucumber/formatter/console'
require 'cucumber/formatter/pretty'
require 'cucumber/rb_support/rb_language'
require 'rspec/mocks'

module Cucumber
  module Formatter
    describe Console do
      extend SpecHelperDsl
      include SpecHelper
      
      before(:each) do
        Cucumber::Term::ANSIColor.coloring = false
        @out = StringIO.new
        @formatter = Pretty.new(runtime, @out, {})
      end

      context "snippets contain relevant keyword replacements" do

        before(:each) do
          run_defined_feature
          @formatter.print_snippets({snippets: 1})
        end

        describe "With a scenario that has undefined steps" do
          define_feature <<-FEATURE
          Feature: Banana party

            Scenario: many monkeys eat many things
              Given there are bananas and apples
              And other monkeys are around
              When one monkey eats a banana
              And the other monkeys eat all the apples
              Then bananas remain
              But there are no apples left
            FEATURE

          it "containes snippets with 'And' or 'But' replaced by previous step name" do
            expect(@out.string).to include("Given(/^there are bananas and apples$/)")
            expect(@out.string).to include("Given(/^other monkeys are around$/)")
            expect(@out.string).to include("When(/^one monkey eats a banana$/)")
            expect(@out.string).to include("When(/^the other monkeys eat all the apples$/)")
            expect(@out.string).to include("Then(/^bananas remain$/)")
            expect(@out.string).to include("Then(/^there are no apples left$/)")
          end
        end

        describe "With a scenario that uses * and 'But'" do
          define_feature <<-FEATURE
          Feature: Banana party

            Scenario: many monkeys eat many things
              * there are bananas and apples
              * other monkeys are around
              When one monkey eats a banana
              * the other monkeys eat all the apples
              Then bananas remain
              * there are no apples left
          FEATURE
          it "replaces the first step with 'Given'" do
            expect(@out.string).to include("Given(/^there are bananas and apples$/)")
          end
          it "uses actual keywords as the 'previous' keyword for future replacements" do
            expect(@out.string).to include("Given(/^other monkeys are around$/)")
            expect(@out.string).to include("When(/^the other monkeys eat all the apples$/)")
            expect(@out.string).to include("Then(/^there are no apples left$/)")
          end
        end

        describe "With a scenario where the only undefined step uses 'And'" do
          define_feature <<-FEATURE
          Feature:

            Scenario:
              Given this step passes
              Then this step passes
              And this step is undefined
          FEATURE
          define_steps do
            Given(/^this step passes$/) {}
          end
          it "uses actual keyword of the previous passing step for the undefined step" do
            expect(@out.string).to include("Then(/^this step is undefined$/)")
          end
        end

      end
    end
  end
end
