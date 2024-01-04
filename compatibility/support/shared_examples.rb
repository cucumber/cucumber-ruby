# frozen_string_literal: true

require 'json'
require 'rspec'
require 'cucumber/messages'

require_relative 'cck/helpers'
require_relative 'cck/messages_comparator'
require_relative 'cck/keys_checker'

RSpec.shared_examples 'cucumber compatibility kit' do
  include CCK::Helpers

  # NOTE: to use those examples, you need to define:
  # let(:example) {  } # the name of the example to test
  # let(:messages) {  } # the messages to validate

  let(:example) { raise '`example` missing: add `let(:example) { example_name }` to your spec' }
  let(:messages) { raise '`messages` missing: add `let(:messages) { ndjson }` to your spec' }

  let(:example_path) { CCK::CompatibilityKit.example_path(example) }

  let(:parsed_original) { parse_ndjson_file("#{example_path}/#{example}.feature.ndjson") }
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

  def parse_ndjson_file(path)
    parse_ndjson(File.read(path))
  end

  def parse_ndjson(ndjson)
    Cucumber::Messages::NdjsonToMessageEnumerator.new(ndjson)
  end
end
