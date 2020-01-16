# frozen_string_literal: true

require 'spec_helper'
require 'cucumber/formatter/spec_helper'
require 'cucumber/formatter/test_pickle_finder'

module Cucumber
  module Formatter
    describe TestPickleFinder do
      extend SpecHelperDsl
      include SpecHelper

      before(:each) do
        Cucumber::Term::ANSIColor.coloring = false
        @test_cases = []

        @out = StringIO.new
        @config = actual_runtime.configuration.with_options(out_stream: @out)
        @formatter = TestPickleFinder.new(@config)

        @config.on_event :test_case_created do |event|
          @test_cases << event.test_case
        end
      end

      describe 'given a single feature' do
        before(:each) do
          run_defined_feature
        end

        describe 'with a scenario' do
          context '#pickle_id' do
            define_feature <<-FEATURE
              Feature: Banana party

                Scenario: Monkey eats banana
                  Given there are bananas
            FEATURE

            it 'provides the ID of the pickle used to generate the Test::Case' do
              # IDs are predictable:
              # - 1 -> scenario
              # - 2 -> first step
              # - 3 -> the pickle
              expect(@formatter.pickle_id(@test_cases.first)).to eq('3')
            end

            it 'raises an error when the Test::Case is unknown' do
              test_case = double
              allow(test_case).to receive(:id).and_return('whatever-id')

              expect { @formatter.pickle_id(test_case) }.to raise_error(Cucumber::Formatter::TestCaseUnknownError)
            end
          end
        end
      end
    end
  end
end
