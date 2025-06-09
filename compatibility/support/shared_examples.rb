# frozen_string_literal: true

require 'json'
require 'rspec'
require 'cucumber/messages'

require_relative 'cck/helpers'
require_relative 'cck/messages_comparator'

RSpec.shared_examples 'cucumber compatibility kit' do
  include CCK::Helpers

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

  it 'ensures a consistent `testRunStartedId` across the entire test run' do
    test_run_started_id = parsed_generated.detect { |msg| message_type(msg) == :test_run_started }.test_run_started.id
    ids = parsed_generated.filter_map do |msg|
      # These two types of message are the only ones containing the testRunStartedId attribute
      msg.send(message_type(msg)).test_run_started_id if %i[test_case test_run_finished].include?(message_type(msg))
    end

    expect(ids).to all eq(test_run_started_id)
  end
end
