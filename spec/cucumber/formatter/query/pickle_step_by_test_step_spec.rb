# frozen_string_literal: true

require 'spec_helper'
require 'cucumber/formatter/spec_helper'
require 'cucumber/formatter/query/pickle_step_by_test_step'

module Cucumber
  module Formatter
    module Query
      describe PickleStepByTestStep do
        extend SpecHelperDsl
        include SpecHelper

        before(:each) do
          Cucumber::Term::ANSIColor.coloring = false
          @test_cases = []

          @out = StringIO.new
          @config = actual_runtime.configuration.with_options(out_stream: @out)
          @formatter = PickleStepByTestStep.new(@config)

          @config.on_event :test_case_created do |event|
            @test_cases << event.test_case
          end

          @pickle_steps = []
          @pickle_step_ids = []
          @config.on_event :envelope do |event|
            next unless event.envelope.pickle

            event.envelope.pickle.steps.each do |step|
              @pickle_steps << step
              @pickle_step_ids << step.id
            end
          end
        end

        describe 'given a single feature' do
          before(:each) do
            run_defined_feature
          end

          describe 'with a scenario' do
            context '#pickle_step_id' do
              define_feature <<-FEATURE
                Feature: Banana party

                  Scenario: Monkey eats banana
                    Given there are bananas
              FEATURE

              it 'provides the ID of the PickleStep used to generate the Test::Step' do
                test_case = @test_cases.first
                test_step = test_case.test_steps.first

                expect(@formatter.pickle_step_id(test_step)).to eq(@pickle_step_ids.first)
              end

              it 'raises an exception when the test_step is unknown' do
                test_step = double
                allow(test_step).to receive(:id).and_return('whatever-id')

                expect { @formatter.pickle_step_id(test_step) }.to raise_error(Cucumber::Formatter::TestStepUnknownError)
              end
            end

            context '#pickle_step' do
              define_feature <<-FEATURE
                Feature: Banana party

                  Scenario: Monkey eats banana
                    Given there are bananas
              FEATURE

              it 'provides the PickleStep used to generate the Test::Step' do
                test_case = @test_cases.first
                test_step = test_case.test_steps.first

                expect(@formatter.pickle_step(test_step)).to eq(@pickle_steps.first)
              end

              it 'raises an exception when the test_step is unknown' do
                test_step = double
                allow(test_step).to receive(:id).and_return('whatever-id')

                expect { @formatter.pickle_step(test_step) }.to raise_error(Cucumber::Formatter::TestStepUnknownError)
              end
            end
          end
        end
      end
    end
  end
end
