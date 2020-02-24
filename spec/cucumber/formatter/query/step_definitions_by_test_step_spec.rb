# frozen_string_literal: true

require 'spec_helper'
require 'cucumber/formatter/spec_helper'
require 'cucumber/formatter/query/step_definitions_by_test_step'

module Cucumber
  module Formatter
    module Query
      describe StepDefinitionsByTestStep do
        extend SpecHelperDsl
        include SpecHelper

        before(:each) do
          Cucumber::Term::ANSIColor.coloring = false
          @test_cases = []

          @out = StringIO.new
          @config = actual_runtime.configuration.with_options(out_stream: @out)
          @formatter = StepDefinitionsByTestStep.new(@config)

          @config.on_event :test_case_created do |event|
            @test_cases << event.test_case
          end

          @step_definition_ids = []
          @config.on_event :envelope do |event|
            next unless event.envelope.step_definition

            @step_definition_ids << event.envelope.step_definition.id
          end
        end

        describe 'given a single feature' do
          before(:each) do
            run_defined_feature
          end

          context '#step_definition_ids' do
            context 'with a matching step' do
              define_steps do
                Given(/^there are bananas$/) {}
              end

              define_feature <<-FEATURE
                Feature: Banana party

                  Scenario: Monkey eats banana
                    Given there are bananas
              FEATURE

              it 'provides the ID of the StepDefinition that matches Test::Step' do
                test_case = @test_cases.first
                test_step = test_case.test_steps.first

                expect(@formatter.step_definition_ids(test_step)).to eq([@step_definition_ids.first])
              end
            end

            context 'with a step that was not activated' do
              context 'when there is no match' do
                define_feature <<-FEATURE
                  Feature: Banana party

                    Scenario: Monkey eats banana
                      Given there are bananas
                FEATURE

                it 'returns an empty array' do
                  test_case = @test_cases.first
                  test_step = test_case.test_steps.first

                  expect(@formatter.step_definition_ids(test_step)).to be_empty
                end
              end

              context 'when there are multiple matches' do
                define_steps do
                  Given(/^there are bananas$/) {}
                  Given(/^there .* bananas$/) {}
                end

                define_feature <<-FEATURE
                  Feature: Banana party

                    Scenario: Monkey eats banana
                      Given there are bananas
                FEATURE

                it 'returns an empty array as the step is not activated' do
                  test_case = @test_cases.first
                  test_step = test_case.test_steps.first

                  expect(@formatter.step_definition_ids(test_step)).to be_empty
                end
              end
            end

            context 'with an unknown step' do
              define_feature 'Feature: Banana party'

              it 'raises an exception' do
                test_step = double
                allow(test_step).to receive(:id).and_return('whatever-id')

                expect { @formatter.step_definition_ids(test_step) }.to raise_error(Cucumber::Formatter::TestStepUnknownError)
              end
            end
          end

          context '#step_match_arguments' do
            context 'with a matching step without arguments' do
              define_steps do
                Given(/^there are bananas$/) {}
              end

              define_feature <<-FEATURE
                Feature: Banana party

                  Scenario: Monkey eats banana
                    Given there are bananas
              FEATURE

              it 'returns an empty list' do
                test_case = @test_cases.first
                test_step = test_case.test_steps.first

                expect(@formatter.step_match_arguments(test_step)).to be_empty
              end
            end

            context 'with a matching step with arguments' do
              define_steps do
                Given(/^there are (.*)$/) {}
              end

              define_feature <<-FEATURE
                Feature: Banana party

                  Scenario: Monkey eats banana
                    Given there are bananas
              FEATURE

              it 'returns an empty list' do
                test_case = @test_cases.first
                test_step = test_case.test_steps.first
                matches = @formatter.step_match_arguments(test_step)

                expect(matches.count).to eq(1)
                expect(matches.first).to be_a(Cucumber::CucumberExpressions::Argument)
                expect(matches.first.group.value).to eq('bananas')
              end
            end

            context 'with an unknown step' do
              define_feature 'Feature: Banana party'

              it 'raises an exception' do
                test_step = double
                allow(test_step).to receive(:id).and_return('whatever-id')

                expect { @formatter.step_match_arguments(test_step) }.to raise_error(Cucumber::Formatter::TestStepUnknownError)
              end
            end
          end
        end
      end
    end
  end
end
