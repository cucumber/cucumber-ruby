# frozen_string_literal: true

require 'rspec'
require 'cucumber/messages'
require_relative '../../support/cck/keys_checker'

describe CCK::KeysChecker do
  describe '#compare' do
    let(:expected_values) { Cucumber::Messages::Attachment.new(url: 'https://foo.com', file_name: 'file.extension') }
    let(:erroneous_values) { Cucumber::Messages::Attachment.new(source: '1', test_step_id: '123') }
    let(:wrong_values) { Cucumber::Messages::Attachment.new(url: 'https://otherfoo.com', file_name: 'file.other') }

    it 'finds missing keys' do
      expect(described_class.compare(erroneous_values, expected_values)).to include(
        'Missing keys in message Cucumber::Messages::Attachment: [:file_name, :url]'
      )
    end

    it 'finds extra keys' do
      expect(described_class.compare(erroneous_values, expected_values)).to include(
        'Detected extra keys in message Cucumber::Messages::Attachment: [:source, :test_step_id]'
      )
    end

    it 'finds extra and missing keys' do
      expect(described_class.compare(erroneous_values, expected_values)).to contain_exactly(
        'Missing keys in message Cucumber::Messages::Attachment: [:file_name, :url]',
        'Detected extra keys in message Cucumber::Messages::Attachment: [:source, :test_step_id]'
      )
    end

    it 'does not care about the values' do
      expect(described_class.compare(expected_values, wrong_values)).to be_empty
    end

    context 'when default values are omitted' do
      let(:default_set) { Cucumber::Messages::Duration.new(seconds: 0, nanos: 12) }
      let(:default_not_set) { Cucumber::Messages::Duration.new(nanos: 12) }

      it 'does not raise an exception' do
        expect(described_class.compare(default_set, default_not_set)).to be_empty
      end
    end

    context 'when executed as part of a CI' do
      before { allow(ENV).to receive(:[]).with('CI').and_return(true) }

      it 'ignores actual CI related messages' do
        detected = Cucumber::Messages::Meta.new(ci: Cucumber::Messages::Ci.new(name: 'Some CI'))
        expected = Cucumber::Messages::Meta.new

        expect(described_class.compare(detected, expected)).to be_empty
      end
    end

    context 'when an unexpected error occurs' do
      it 'does not raise error' do
        expect { described_class.compare(nil, nil) }.not_to raise_error
      end

      it 'returns the error to be debugged' do
        expect(described_class.compare(nil, nil).first).to end_with('wrong number of arguments (given 1, expected 0)')
      end
    end
  end
end
