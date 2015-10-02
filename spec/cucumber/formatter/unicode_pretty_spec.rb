# coding: utf-8

require 'spec_helper'
require 'cucumber/formatter/spec_helper'
require 'cucumber/formatter/pretty'
require 'cucumber/cli/options'

unless Cucumber::JRUBY
  require 'unicode'

  module Cucumber
    module Formatter
      describe Pretty do
        extend SpecHelperDsl
        include SpecHelper

        before(:each) do
          Cucumber::Term::ANSIColor.coloring = false
          @out = StringIO.new
          @formatter = Pretty.new(runtime, @out, {})
        end

        describe "with a multiline step arg including fullwidth characters" do
          define_feature <<-FEATURE
                  Feature: Traveling circus

                    Scenario: Monkey goes to town
                      Given there are monkeys:
                       | 名前 |
                       | キュウリ |
                       | Cucumber |
          FEATURE

          it "displays the multiline string" do
            run_defined_feature

            expect(@out.string).to include <<OUTPUT
    Given there are monkeys:
      | 名前     |
      | キュウリ |
      | Cucumber |
OUTPUT
          end
        end

        describe "with a multiline step arg including ambiguous width characters" do
          define_feature <<-FEATURE
                  Feature: Traveling circus

                    Scenario: Monkey goes to town
                      Given there are monkeys:
                       | ∀ |
                       | forall |
          FEATURE

          after :each do
            Cucumber.treats_ambiguous_as_fullwidth = nil
          end

          it "prints as fullwidth" do
            Cucumber.treats_ambiguous_as_fullwidth = true
            run_defined_feature

            expect(@out.string).to include <<OUTPUT
    Given there are monkeys:
      | ∀     |
      | forall |
OUTPUT
          end

          it "prints as halfwidth" do
            Cucumber.treats_ambiguous_as_fullwidth = false
            run_defined_feature

            expect(@out.string).to include <<OUTPUT
    Given there are monkeys:
      | ∀      |
      | forall |
OUTPUT
          end
        end
      end
    end
  end
end
