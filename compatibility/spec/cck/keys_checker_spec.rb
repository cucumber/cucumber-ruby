# frozen_string_literal: true

require 'rspec'
require 'cucumber/messages'
require_relative '../../support/cck/keys_checker'

describe CCK::KeysChecker do
  describe '#compare' do
    let(:expected_kvps) { Cucumber::Messages::Attachment.new(url: 'https://foo.com', file_name: 'file.extension', test_step_id: 123_456) }
    let(:missing_kvps) { Cucumber::Messages::Attachment.new(url: 'https://foo.com') }
    let(:extra_kvps) { Cucumber::Messages::Attachment.new(url: 'https://foo.com', file_name: 'file.extension', test_step_id: 123_456, source: '1') }
    let(:missing_and_extra_kvps) { Cucumber::Messages::Attachment.new(file_name: 'file.extension', test_step_id: 123_456, test_run_started_id: 123_456) }
    let(:wrong_values) { Cucumber::Messages::Attachment.new(url: 'https://otherfoo.com', file_name: 'file.other', test_step_id: 456_789) }

    it 'finds missing keys' do
      expect(described_class.compare(missing_kvps, expected_kvps)).to eq(
        'Missing keys in message Cucumber::Messages::Attachment: [:file_name, :test_step_id]'
      )
    end

    it 'finds extra keys' do
      expect(described_class.compare(extra_kvps, expected_kvps)).to eq(
        'Detected extra keys in message Cucumber::Messages::Attachment: [:source]'
      )
    end

    it 'finds the extra keys first' do
      expect(described_class.compare(missing_and_extra_kvps, expected_kvps)).to eq(
        'Detected extra keys in message Cucumber::Messages::Attachment: [:test_run_started_id]'
      )
    end

    it 'does not care about the values' do
      expect(described_class.compare(expected_kvps, wrong_values)).to be_nil
    end

    context 'when default values are omitted' do
      let(:default_set) { Cucumber::Messages::Duration.new(seconds: 0, nanos: 12) }
      let(:default_not_set) { Cucumber::Messages::Duration.new(nanos: 12) }

      it 'does not raise an exception' do
        expect(described_class.compare(default_set, default_not_set)).to be_nil
      end
    end

    context 'when executed as part of a CI' do
      before { allow(ENV).to receive(:[]).with('CI').and_return(true) }

      it 'ignores actual CI related messages' do
        detected = Cucumber::Messages::Meta.new(ci: Cucumber::Messages::Ci.new(name: 'Some CI'))
        expected = Cucumber::Messages::Meta.new

        expect(described_class.compare(detected, expected)).to be_nil
      end
    end

    context 'when an unexpected error occurs' do
      it 'does not raise error' do
        expect { described_class.compare(nil, nil) }.not_to raise_error
      end

      it 'returns the error to be debugged' do
        expect(described_class.compare(nil, nil)).to include(/wrong number of arguments \(given 1, expected 0\)/)
      end
    end
  end
end
