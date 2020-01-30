require 'json'
require 'rspec'

def message_type(message)
  message.keys.first
end

def parse_ndjson(path)
  File.read(path).split("\n").map do |line|
    JSON.parse(line)
  end
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
end
