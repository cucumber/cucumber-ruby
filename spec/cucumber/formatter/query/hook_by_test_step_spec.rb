# frozen_string_literal: true

require 'spec_helper'
require 'cucumber/formatter/spec_helper'
require 'cucumber/formatter/query/hook_by_test_step'

module Cucumber
  module Formatter
    module Query
      describe HookByTestStep do
        extend SpecHelperDsl
        include SpecHelper

        before(:each) do
          Cucumber::Term::ANSIColor.coloring = false
          @test_cases = []

          @out = StringIO.new
          @config = actual_runtime.configuration.with_options(out_stream: @out)
          @formatter = HookByTestStep.new(@config)

          @config.on_event :test_case_started do |event|
            @test_cases << event.test_case
          end

          @hook_ids = []
          @config.on_event :envelope do |event|
            next unless event.envelope.hook

            @hook_ids << event.envelope.hook.id
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

              define_steps do
                Before() {}
                After() {}
              end

              it 'provides the ID of the Before Hook used to generate the Test::Step' do
                test_case = @test_cases.first
                expect(@formatter.hook_id(test_case.test_steps.first)).to eq(@hook_ids.first)
              end

              it 'provides the ID of the After Hook used to generate the Test::Step' do
                test_case = @test_cases.first
                expect(@formatter.hook_id(test_case.test_steps.last)).to eq(@hook_ids.last)
              end

              it 'returns nil if the step was not generated from a hook' do
                test_case = @test_cases.first
                expect(@formatter.hook_id(test_case.test_steps[1])).to be_nil
              end

              it 'raises an exception when the test_step is unknown' do
                test_step = double
                allow(test_step).to receive(:id).and_return('whatever-id')

                expect { @formatter.hook_id(test_step) }.to raise_error(Cucumber::Formatter::TestStepUnknownError)
              end
            end
          end

          describe 'with AfterStep hooks' do
            context '#pickle_step_id' do
              define_feature <<-FEATURE
                Feature: Banana party

                  Scenario: Monkey eats banana
                    Given there are bananas
              FEATURE

              define_steps do
                AfterStep() {}
              end

              it 'provides the ID of the AfterStepHook used to generate the Test::Step' do
                test_case = @test_cases.first
                expect(@formatter.hook_id(test_case.test_steps.last)).to eq(@hook_ids.first)
              end
            end
          end
        end
      end
    end
  end
end
