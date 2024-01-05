# frozen_string_literal: true

require 'rspec'
require 'cucumber/messages'
require_relative '../../support/cck/messages_comparator'

describe CCK::MessagesComparator do
  context 'when executed as part of a CI' do
    before { allow(ENV).to receive(:[]).with('CI').and_return(true) }

    let(:ci_message) { Cucumber::Messages::Ci.new(name: 'Some CI') }
    let(:blank_meta_message) { Cucumber::Messages::Meta.new }
    let(:filled_meta_message) { Cucumber::Messages::Meta.new(ci: ci_message) }
    let(:ci_message_envelope) { Cucumber::Messages::Envelope.new(meta: filled_meta_message) }
    let(:meta_message_envelope) { Cucumber::Messages::Envelope.new(meta: blank_meta_message) }

    it 'ignores any detected CI messages' do
      comparator = described_class.new([ci_message_envelope], [meta_message_envelope])

      expect(comparator.errors).to be_empty
    end

    it 'ignores any expected CI messages' do
      comparator = described_class.new([meta_message_envelope], [ci_message_envelope])

      expect(comparator.errors).to be_empty
    end
  end
end
