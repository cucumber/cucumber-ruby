# frozen_string_literal: true

def sources
  [
    "#{Dir.pwd}/spec/support/empty.ndjson",
    "#{Dir.pwd}/spec/support/minimal.ndjson"
  ]
end

def list_of_queries
  {
    'findAllPickles' => ->(query) { query.find_all_pickles.length }
  }
end

def list_of_tests
  tests ||= []
  sources.each do |source|
    list_of_queries.each do |query|
      tests << [source, query]
    end
  end
  tests
end

def parse_ndjson_file(path)
  parse_ndjson(File.read(path))
end

def parse_ndjson(ndjson)
  Cucumber::Messages::Helpers::NdjsonToMessageEnumerator.new(ndjson)
end

require 'cucumber/query'
require 'cucumber/messages'

# This is the new query spec
describe Cucumber::Query do
  subject(:query) { described_class.new(repository) }

  let(:repository) { Cucumber::Repository.new }

  describe 'all of our tests' do
    list_of_tests.each do |line_item|
      it "Executes the following queries '#{line_item.last.first}' against the CCK definition provided by #{line_item.first}" do
        message_array = parse_ndjson_file(line_item.first).map { |msg| msg }
        message_array.each { |msg| repository.update(msg) }

        name = line_item.last.first
        query_proc = line_item.last.last
        name_of_file_to_check = line_item.first.sub('.ndjson', ".#{name}.results.json")
        answer = File.read(name_of_file_to_check)

        expect(query_proc.call(query)).to eq(JSON.parse(answer))
      end
    end
  end
end
