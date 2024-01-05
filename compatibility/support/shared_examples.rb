# frozen_string_literal: true

require 'json'
require 'rspec'
require 'cucumber/messages'

require_relative 'cck/helpers'
require_relative 'cck/messages_comparator'

require 'cucumber-compatibility-kit'

RSpec.shared_examples 'cucumber compatibility kit' do
  include CCK::Helpers

  let(:support_code_path) { CCK::Examples.supporting_code_for(example) }
  let(:cck_path) { CCK::Examples.feature_code_for(example) }

  let(:parsed_original) { parse_ndjson_file("#{cck_path}/#{example}.feature.ndjson") }
  let(:parsed_generated) { parse_ndjson(messages) }

  let(:original_messages_types) { parsed_original.map { |msg| message_type(msg) } }
  let(:generated_messages_types) { parsed_generated.map { |msg| message_type(msg) } }

  it 'generates valid message types' do
    expect(generated_messages_types).to contain_exactly(*original_messages_types)
  end

  it 'generates valid message structure' do
    comparator = CCK::MessagesComparator.new(parsed_generated, parsed_original)

    expect(comparator.errors).to be_empty, "There were comparison errors: #{comparator.errors}"
  end
end
