# frozen_string_literal: true
require 'cucumber'
require 'cucumber/filters/retry'
require 'cucumber/core/gherkin/writer'
require 'cucumber/configuration'
require 'cucumber/core/test/case'
require 'cucumber/core'
require 'cucumber/events'

describe Cucumber::Filters::Retry do
  include Cucumber::Core::Gherkin::Writer
  include Cucumber::Core
  include Cucumber::Events

  let(:configuration) { Cucumber::Configuration.new(:retry => 2) }
  let(:test_case) { Cucumber::Core::Test::Case.new([double('test steps')], double('source').as_null_object) }
  let(:receiver) { double('receiver').as_null_object }
  let(:filter) { Cucumber::Filters::Retry.new(configuration, receiver) }
  let(:fail) { Cucumber::Events::AfterTestCase.new(test_case, double('result', :failed? => true, :ok? => false)) }
  let(:pass) { Cucumber::Events::AfterTestCase.new(test_case, double('result', :failed? => false, :ok? => true)) }

  it { is_expected.to respond_to(:test_case) }
  it { is_expected.to respond_to(:with_receiver) }
  it { is_expected.to respond_to(:done) }

  context 'passing test case' do
    let(:result) { Cucumber::Core::Test::Result::Passed.new(0) }

    it 'describes the test case once' do
      expect(receiver).to receive(:test_case).with(test_case).once
      test_case.describe_to filter
      configuration.notify :test_case_finished, test_case, result
    end
  end

  context 'when performing retry' do
    let(:result) { Cucumber::Core::Test::Result::Failed.new(0, StandardError.new) }

    it 'describes the same test case object each time' do
      allow(receiver).to receive(:test_case) {|tc|
        expect(tc).to equal(test_case)
        configuration.notify :test_case_finished, tc.with_steps(tc.test_steps), result
      }

      filter.test_case(test_case)
    end
  end

  context 'consistently failing test case' do
    let(:result) { Cucumber::Core::Test::Result::Failed.new(0, StandardError.new) }

    it 'describes the test case the specified number of times' do
      expect(receiver).to receive(:test_case) {|test_case|
        configuration.notify :test_case_finished, test_case, result
      }.exactly(3).times

      filter.test_case(test_case)
    end
  end

  context 'flaky test cases' do

    context 'a little flaky' do
      let(:results) {
        [
          Cucumber::Core::Test::Result::Failed.new(0, StandardError.new),
          Cucumber::Core::Test::Result::Passed.new(0)
        ]
      }

      it 'describes the test case twice' do
        expect(receiver).to receive(:test_case) {|test_case|
          configuration.notify :test_case_finished, test_case, results.shift
        }.exactly(2).times

        filter.test_case(test_case)
      end
    end

    context 'really flaky' do
      let(:results) {
        [
          Cucumber::Core::Test::Result::Failed.new(0, StandardError.new),
          Cucumber::Core::Test::Result::Failed.new(0, StandardError.new),
          Cucumber::Core::Test::Result::Passed.new(0)
        ]
      }

      it 'describes the test case 3 times' do
        expect(receiver).to receive(:test_case) {|test_case|
          configuration.notify :test_case_finished, test_case, results.shift
        }.exactly(3).times

        filter.test_case(test_case)
      end
    end
  end
end
