require 'rspec'
require 'cucumber/messages'
require_relative '../lib/keys_checker'

describe CCK::KeysChecker do
  let(:subject) { CCK::KeysChecker }

  describe '#compare' do
    let(:complete) do
      Cucumber::Messages::Duration.new(
        seconds: 1,
        nanos: 12
      )
    end

    let(:missing_nanos) do
      Cucumber::Messages::Duration.new(
        seconds: 1
      )
    end

    let(:missing_seconds) do
      Cucumber::Messages::Duration.new(
        nanos: 1
      )
    end

    let(:wrong_values) do
      Cucumber::Messages::Duration.new(
        seconds: 123,
        nanos: 456
      )
    end

    it 'finds missing key' do
      expect(subject.compare(missing_nanos, complete)).to eq(
        ['Missing keys in message Cucumber::Messages::Duration: [:nanos]']
      )
    end

    it 'finds extra keys' do
      expect(subject.compare(complete, missing_seconds)).to eq(
        ['Found extra keys in message Cucumber::Messages::Duration: [:seconds]']
      )
    end

    it 'finds extra and missing' do
      expect(subject.compare(missing_nanos, missing_seconds)).to contain_exactly(
        'Missing keys in message Cucumber::Messages::Duration: [:nanos]',
        'Found extra keys in message Cucumber::Messages::Duration: [:seconds]'
      )
    end

    it 'does not care about the values' do
      expect(subject.compare(complete, wrong_values)).to be_empty
    end

    context 'when default values are omitted' do
      # Depending on protobuf implementations, some default values may be omitted
      # on JSON generation. So for once, we'll check the values, just in case.

      let(:default_set) do
        Cucumber::Messages::Duration.new(
          seconds: 0,
          nanos: 12
        )
      end

      let(:default_not_set) do
        Cucumber::Messages::Duration.new(
          nanos: 12
        )
      end

      it 'does not raise an exception' do
        expect(subject.compare(default_set, default_not_set)).to be_empty
      end
    end
  end
end
