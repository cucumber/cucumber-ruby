# frozen_string_literal: true

require 'json'
require 'rspec'
require 'cucumber/messages'

require_relative 'cck_new/helpers'
require_relative 'cck_new/messages_comparator'
require_relative 'cck_new/keys_checker'

require 'cucumber-compatibility-kit'

RSpec.shared_examples 'cucumber compatibility kit' do
  include CCKNew::Helpers

  let(:cck_implementation_path) { CCKNew::CompatibilityKit.example_path(example) }
  let(:cck_features_path) { Cucumber::CompatibilityKit.example_path(example) }

  let(:parsed_original) { parse_ndjson_file("#{cck_features_path}/#{example}.feature.ndjson") }
  let(:parsed_generated) { parse_ndjson(messages) }

  let(:original_messages_types) { parsed_original.map { |msg| message_type(msg) } }
  let(:generated_messages_types) { parsed_generated.map { |msg| message_type(msg) } }

  it 'generates valid message types' do
    expect(generated_messages_types).to contain_exactly(*original_messages_types)
  end

  it 'generates valid message structure' do
    comparator = CCKNew::MessagesComparator.new(parsed_generated, parsed_original)

    expect(comparator.errors).to be_empty, "There were comparison errors: #{comparator.errors}"
  end

  def parse_ndjson_file(path)
    parse_ndjson(File.read(path))
  end

  def parse_ndjson(ndjson)
    Cucumber::Messages::NdjsonToMessageEnumerator.new(ndjson)
  end
end
