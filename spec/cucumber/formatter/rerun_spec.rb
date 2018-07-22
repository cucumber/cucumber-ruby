# frozen_string_literal: true

require 'cucumber/formatter/rerun'
require 'cucumber/core'
require 'cucumber/core/gherkin/writer'
require 'cucumber/core/filter'
require 'support/standard_step_actions'
require 'cucumber/configuration'

module Cucumber
  module Formatter
    describe Rerun do
      include Cucumber::Core::Gherkin::Writer
      include Cucumber::Core

      let(:config) { Cucumber::Configuration.new(out_stream: io) }
      let(:io) { StringIO.new }

      # after_test_case
      context 'when 2 scenarios fail in the same file' do
        it 'Prints the locations of the failed scenarios' do
          gherkin = gherkin('foo.feature') do
            feature do
              scenario do
                step 'failing'
              end

              scenario do
                step 'failing'
              end

              scenario do
                step 'passing'
              end
            end
          end
          Rerun.new(config)
          execute [gherkin], [StandardStepActions.new], config.event_bus
          config.event_bus.test_run_finished

          expect(io.string).to eq 'foo.feature:3:6'
        end
      end

      context 'with failures in multiple files' do
        it 'prints the location of the failed scenarios in each file' do
          foo = gherkin('foo.feature') do
            feature do
              scenario do
                step 'failing'
              end

              scenario do
                step 'failing'
              end

              scenario do
                step 'passing'
              end
            end
          end

          bar = gherkin('bar.feature') do
            feature do
              scenario do
                step 'failing'
              end
            end
          end

          Rerun.new(config)
          execute [foo, bar], [StandardStepActions.new], config.event_bus
          config.event_bus.test_run_finished

          expect(io.string).to eq "foo.feature:3:6\nbar.feature:3"
        end
      end

      context 'when there are no failing scenarios' do
        it 'prints nothing' do
          gherkin = gherkin('foo.feature') do
            feature do
              scenario do
                step 'passing'
              end
            end
          end

          Rerun.new(config)
          execute [gherkin], [StandardStepActions.new], config.event_bus
          config.event_bus.test_run_finished

          expect(io.string).to eq ''
        end
      end

      context 'with only a flaky scenarios' do
        class FlakyStepActions < Cucumber::Core::Filter.new
          def test_case(test_case)
            failing_test_steps = test_case.test_steps.map do |step|
              step.with_action { raise Failure }
            end
            passing_test_steps = test_case.test_steps.map do |step|
              step.with_action {}
            end

            test_case.with_steps(failing_test_steps).describe_to(receiver)
            test_case.with_steps(passing_test_steps).describe_to(receiver)
          end
        end

        context 'with option --no-strict-flaky' do
          it 'prints nothing' do
            gherkin = gherkin('foo.feature') do
              feature do
                scenario do
                  step 'flaky'
                end
              end
            end

            Rerun.new(config)
            execute [gherkin], [FlakyStepActions.new], config.event_bus
            config.event_bus.test_run_finished

            expect(io.string).to eq ''
          end
        end
        context 'with option --strict-flaky' do
          let(:config) { Configuration.new(out_stream: io, strict: Core::Test::Result::StrictConfiguration.new([:flaky])) }

          it 'prints the location of the flaky scenario' do
            foo = gherkin('foo.feature') do
              feature do
                scenario do
                  step 'flaky'
                end
              end
            end

            Rerun.new(config)
            execute [foo], [FlakyStepActions.new], config.event_bus
            config.event_bus.test_run_finished

            expect(io.string).to eq 'foo.feature:3'
          end

          it 'does not include retried failing scenarios more than once' do
            foo = gherkin('foo.feature') do
              feature do
                scenario do
                  step 'failing'
                end
              end
            end

            Rerun.new(config)
            execute [foo, foo], [StandardStepActions.new], config.event_bus
            config.event_bus.test_run_finished

            expect(io.string).to eq 'foo.feature:3'
          end
        end
      end
    end
  end
end
