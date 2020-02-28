# frozen_string_literal: true

require 'spec_helper'
require 'cucumber/formatter/spec_helper'
require 'cucumber/formatter/query/test_case_started_by_test_case'

module Cucumber
  module Formatter
    module Query
      describe TestCaseStartedByTestCase do
        extend SpecHelperDsl
        include SpecHelper

        before(:each) do
          Cucumber::Term::ANSIColor.coloring = false

          @out = StringIO.new
          @config = actual_runtime.configuration.with_options(out_stream: @out)
          @formatter = TestCaseStartedByTestCase.new(@config)
        end

        let(:unknown_test_case) do
          test_case = double
          allow(test_case).to receive(:id).and_return('whatever-id')
          test_case
        end

        context '#attempt_by_test_case' do
          it 'raises an exception when the TestCase is unknown' do
            expect { @formatter.attempt_by_test_case(unknown_test_case) }.to raise_exception(TestCaseUnknownError)
          end

          context 'when the test case has been declared' do
            before do
              @test_case = double
              allow(@test_case).to receive(:id).and_return('some-valid-id')

              @config.notify :test_case_created, @test_case, nil
            end

            it 'returns 0 if no test_case_started event has been fired' do
              expect(@formatter.attempt_by_test_case(@test_case)).to eq(0)
            end

            it 'increments the attemp on every test_case_started event' do
              @config.notify :test_case_started, @test_case
              expect(@formatter.attempt_by_test_case(@test_case)).to eq(1)

              @config.notify :test_case_started, @test_case
              expect(@formatter.attempt_by_test_case(@test_case)).to eq(2)
            end
          end
        end

        context '#test_case_started_id_by_test_case' do
          it 'raises an exception when the TestCase is unknown' do
            expect { @formatter.test_case_started_id_by_test_case(unknown_test_case) }.to raise_exception(TestCaseUnknownError)
          end

          context 'when the test case has been declared' do
            before do
              @test_case = double
              allow(@test_case).to receive(:id).and_return('some-valid-id')

              @config.notify :test_case_created, @test_case, nil
            end

            it 'returns nil if no test_case_started event has been fired' do
              expect(@formatter.test_case_started_id_by_test_case(@test_case)).to be_nil
            end

            it 'gives a new id when a test_case_started event is fired' do
              @config.notify :test_case_started, @test_case

              first_attempt_id = @formatter.test_case_started_id_by_test_case(@test_case)
              expect(first_attempt_id).not_to be_nil

              @config.notify :test_case_started, @test_case
              second_attempt_id = @formatter.test_case_started_id_by_test_case(@test_case)
              expect(second_attempt_id).not_to be_nil

              expect(second_attempt_id).not_to eq(first_attempt_id)
            end
          end
        end
      end
    end
  end
end
