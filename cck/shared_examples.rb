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

RSpec.shared_examples 'equivalent messages' do
  # Note: to use those examples, you need to define:
  # let(:original) { 'path to .ndjson file in CCK' }
  # let(:generated) { 'patht o generated .ndjson file' }

  let(:parsed_original) { parse_ndjson(original) }
  let(:parsed_generated) { parse_ndjson(generated) }

  it 'has the same number of messages' do
    expect(parsed_generated.count).to eq(parsed_original.count)
  end
end