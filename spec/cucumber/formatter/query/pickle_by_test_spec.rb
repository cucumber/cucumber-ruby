# frozen_string_literal: true

require 'spec_helper'
require 'cucumber/formatter/spec_helper'
require 'cucumber/formatter/query/pickle_by_test'

module Cucumber
  module Formatter
    module Query
      describe PickleByTest do
        extend SpecHelperDsl
        include SpecHelper

        before(:each) do
          Cucumber::Term::ANSIColor.coloring = false
          @test_cases = []

          @out = StringIO.new
          @config = actual_runtime.configuration.with_options(out_stream: @out)
          @formatter = PickleByTest.new(@config)

          @config.on_event :test_case_created do |event|
            @test_cases << event.test_case
          end

          @pickles = []
          @pickle_ids = []
          @config.on_event :envelope do |event|
            next unless event.envelope.pickle

            @pickles << event.envelope.pickle
            @pickle_ids << event.envelope.pickle.id
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
                expect(@formatter.pickle_id(@test_cases.first)).to eq(@pickle_ids.first)
              end

              it 'raises an error when the Test::Case is unknown' do
                test_case = double
                allow(test_case).to receive(:id).and_return('whatever-id')

                expect { @formatter.pickle_id(test_case) }.to raise_error(Cucumber::Formatter::TestCaseUnknownError)
              end
            end

            context '#pickle' do
              define_feature <<-FEATURE
                Feature: Banana party

                  Scenario: Monkey eats banana
                    Given there are bananas
              FEATURE

              it 'provides the pickle used to generate the Test::Case' do
                expect(@formatter.pickle(@test_cases.first)).to eq(@pickles.first)
              end

              it 'raises an error when the Test::Case is unknown' do
                test_case = double
                allow(test_case).to receive(:id).and_return('whatever-id')

                expect { @formatter.pickle(test_case) }.to raise_error(Cucumber::Formatter::TestCaseUnknownError)
              end
            end
          end
        end
      end
    end
  end
end
