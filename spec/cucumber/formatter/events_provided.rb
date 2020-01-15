# frozen_string_literal: true

require 'spec_helper'
require 'cucumber/formatter/spec_helper'
require 'cucumber/formatter/progress'
require 'cucumber/cli/options'

module Cucumber
  module Formatter
    class FakeFormatter
      attr_reader :pickle_by_test_case_id
      attr_reader :pickle_step_by_test_step_id

      def initialize(config)
        @pickle_step_by_test_step_id = {}
        @pickle_by_test_case_id = {}

        config.on_event :test_case_created, &method(:on_test_case_created)
        config.on_event :test_step_created, &method(:on_test_step_created)
      end

      private

      def on_test_case_created(event)
        @pickle_by_test_case_id[event.test_case.id] = event.pickle.id
      end

      def on_test_step_created(event)
        @pickle_step_by_test_step_id[event.test_step.id] = event.pickle_step.id
      end
    end

    describe FakeFormatter do
      extend SpecHelperDsl
      include SpecHelper

      before(:each) do
        Cucumber::Term::ANSIColor.coloring = false
        @out = StringIO.new
        @formatter = FakeFormatter.new(actual_runtime.configuration.with_options(out_stream: @out))
      end

      describe 'given a single feature' do
        before(:each) do
          run_defined_feature
        end

        describe 'with a scenario' do
          define_feature <<-FEATURE
            Feature: Banana party

              Scenario: Monkey eats banana
                Given there are bananas
          FEATURE

          it 'knows the pickle ID for each test' do
            expect(@formatter.pickle_by_test_case_id.length).to eq(1)
          end

          it 'knows the pickle step ID for each test step' do
            expect(@formatter.pickle_step_by_test_step_id.length).to eq(1)
          end

          it 'knows the step definition that matched each step'
          it 'know the hook ID that was used to create steps'
        end
      end
    end
  end
end
