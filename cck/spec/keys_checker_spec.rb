require 'rspec'
require 'cucumber/messages'
require_relative '../lib/keys_checker'

describe CCK::KeysChecker do
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
      expect(CCK::KeysChecker.compare(missing_nanos, complete)).to eq(
        ['Missing keys in message Cucumber::Messages::Duration: [:nanos]']
      )
    end

    it 'finds extra keys' do
      expect(CCK::KeysChecker.compare(complete, missing_seconds)).to eq(
        ['Found extra keys in message Cucumber::Messages::Duration: [:seconds]']
      )
    end

    it 'finds extra and missing' do
      expect(CCK::KeysChecker.compare(missing_nanos, missing_seconds)).to contain_exactly(
        'Missing keys in message Cucumber::Messages::Duration: [:nanos]',
        'Found extra keys in message Cucumber::Messages::Duration: [:seconds]'
      )
    end

    it 'does not care about the values' do
      expect(CCK::KeysChecker.compare(complete, wrong_values)).to be_empty
    end
  end
end
