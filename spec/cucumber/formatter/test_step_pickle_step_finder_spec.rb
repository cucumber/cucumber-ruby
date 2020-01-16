# frozen_string_literal: true

require 'spec_helper'
require 'cucumber/formatter/spec_helper'
require 'cucumber/formatter/test_step_pickle_step_finder'

module Cucumber
  module Formatter
    describe TestStepPickleStepFinder do
      extend SpecHelperDsl
      include SpecHelper

      before(:each) do
        Cucumber::Term::ANSIColor.coloring = false
        @test_cases = []

        @out = StringIO.new
        @config = actual_runtime.configuration.with_options(out_stream: @out)
        @formatter = TestStepPickleStepFinder.new(@config)

        @config.on_event :test_case_created do |event|
          @test_cases << event.test_case
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
              # IDs are predictable:
              # - 0 -> first step
              # - 1 -> scenario
              # - 2 -> pickle step
              # - 3 -> the pickle
              test_case = @test_cases.first
              test_step = test_case.test_steps.first

              expect(@formatter.pickle_step_id(test_step)).to eq('2')
            end

            it 'raises an exception when the test_step is unknown' do
              test_step = double
              allow(test_step).to receive(:id).and_return('whatever-id')

              expect { @formatter.pickle_step_id(test_step) }.to raise_error(Cucumber::Formatter::TestStepUnknownError)
            end
          end
        end
      end
    end
  end
end
