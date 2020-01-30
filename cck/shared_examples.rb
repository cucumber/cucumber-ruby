require 'json'
require 'rspec'
require 'cucumber/messages'

def message_type(message)
  message.to_hash.keys.first
end

def parse_ndjson(path)
  Cucumber::Messages::NdjsonToMessageEnumerator.new(File.read(path))
end

def debug_lists(expected, obtained)
  return unless ENV['VERBOSE']

  to_read = expected.count > obtained.count ? expected : obtained
  columnize = "\t\t\t\t | \t\t\t\t"

  puts "    | Expected #{columnize} GOT"
  to_read.each_with_index do |_, index|
    ok = expected[index] == obtained[index] ? 'v' : 'x'
    puts "[#{ok}] | #{expected[index]} #{columnize} #{obtained[index]}"
  end
end

class MessagesComparator
  attr_reader :errors

  def initialize(found, expected)
    @errors = []
    @compared = []

    compare(found, expected)
  end

  def debug
    puts 'Compared the following type of message:'
    puts @compared.uniq.map { |m| " - #{m}" }.join("\n")
    puts ''
    puts errors.uniq.join("\n")
  end

  private

  def compare(found, expected)
    found_by_type = messages_by_type(found)
    expected_by_type = messages_by_type(expected)

    found_by_type.keys.each do |type|
      compare_list(found_by_type[type], expected_by_type[type])
    end
  end

  def messages_by_type(messages)
    by_type = Hash.new { |h, k| h[k] = [] }
    messages.each do |msg|
      by_type[message_type(msg)] << remove_envelope(msg)
    end
    by_type
  end

  def remove_envelope(message)
    message[message_type(message)]
  end

  def compare_list(found, expected)
    found.each_with_index do |message, index|
      compare_message(message, expected[index])
    end
  end

  def compare_message(found, expected)
    return if found.is_a?(Cucumber::Messages::GherkinDocument)
    return if found.is_a?(Cucumber::Messages::Pickle)

    @compared << found.class.name

    same_keys?(found, expected)

    # TODO: find sub-messages (TestResults etc)
  end

  def same_keys?(found, expected)
    found_keys = found.to_hash.keys
    expected_keys = expected.to_hash.keys

    return if found_keys.sort == expected_keys.sort

    missing_keys = expected_keys - found_keys
    extra_keys = found_keys - expected_keys

    errors << "Found extra keys in message #{found.class.name}: #{extra_keys}" unless extra_keys.empty?
    errors << "Missing keys in message #{found.class.name}: #{missing_keys}" unless missing_keys.empty?
  end
end

RSpec.shared_examples 'equivalent messages' do
  # Note: to use those examples, you need to define:
  # let(:original) { 'path to .ndjson file in CCK' }
  # let(:generated) { 'path to generated .ndjson file' }

  let(:parsed_original) { parse_ndjson(original) }
  let(:parsed_generated) { parse_ndjson(generated) }

  let(:original_messages_types) { parsed_original.map { |msg| message_type(msg) } }
  let(:generated_messages_types) { parsed_generated.map { |msg| message_type(msg) } }

  it 'produces the same kind of messages' do
    debug_lists(original_messages_types, generated_messages_types)
    expect(generated_messages_types).to contain_exactly(*original_messages_types)
  end

  it 'produces messages with the same content' do
    comparator = MessagesComparator.new(parsed_generated, parsed_original)
    comparator.debug if ENV['VERBOSE']

    expect(comparator.errors).to be_empty
  end
end
