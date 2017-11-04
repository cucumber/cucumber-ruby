# frozen_string_literal: true
require 'cucumber/filters/broadcast_test_case_count_event'

describe Cucumber::Filters::BroadcastTestCaseCountEvent do
  subject(:filter) { Cucumber::Filters::BroadcastTestCaseCountEvent.new(config, receiver) }

  let(:event_bus) { double(:event_bus) }
  let(:config) { double(:config) }
  let(:receiver) { double(:receiver) }

  let(:test_case) { double(:test_case) }

  before do
    allow(config).to receive(:event_bus).and_return(event_bus)
  end

  context 'without handler registered for the test case count event' do
    before(:each) do
      allow(event_bus).to receive(:handlers_exist_for?).with(:test_case_count).and_return(false)
    end

    it 'test cases are passed on immediately' do
      expect(test_case).to receive(:describe_to).with(receiver)

      filter.test_case(test_case)
    end
  end

  context 'with handler registered for the test case count event' do
    before(:each) do
      allow(event_bus).to receive(:handlers_exist_for?).with(:test_case_count).and_return(true)
    end

    it 'test cases are not passed on immediately' do
      expect(test_case).not_to receive(:describe_to).with(receiver)

      filter.test_case(test_case)
    end

    it 'test case count event is issued before the the test cases are passed on' do
      expect(config).to receive(:notify).with(:test_case_count, [test_case]).ordered
      expect(test_case).to receive(:describe_to).with(receiver).ordered
      expect(receiver).to receive(:done).ordered

      filter.test_case(test_case)
      filter.done
    end
  end
end
