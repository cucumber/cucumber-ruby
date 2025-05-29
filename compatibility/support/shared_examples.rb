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
    # Step 1) Grab testRunStarted[:id]
    test_run_message = parsed_generated.detect { |msg| message_type(msg) == :test_run_started }
    id = test_run_message.test_run_started.id
    
    # Step 2) Validate every testCase has a [:testRunStartedId] equal to the above
    # Step 3) Validate the single testRunFinished [:testRunStartedId] equal to the above
    messages_types_containing_test_run_started_id = %i[test_case test_run_finished]
    messages_containing_test_run_started_id = parsed_generated.select { |msg| messages_types_containing_test_run_started_id.include?(message_type(msg)) }
    ids = messages_containing_test_run_started_id.map { |msg| msg.send(message_type(msg)).test_run_started_id }

    expect(ids).to all eq(id)
  end
end
