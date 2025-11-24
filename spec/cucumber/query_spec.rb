# frozen_string_literal: true

def sources
  [
    "#{Dir.pwd}/spec/support/attachments.ndjson",
    "#{Dir.pwd}/spec/support/empty.ndjson",
    "#{Dir.pwd}/spec/support/hooks.ndjson",
    "#{Dir.pwd}/spec/support/minimal.ndjson",
  ]
end

def list_of_queries
  {
    'findAllPickles' => ->(query) { query.find_all_pickles.length }
  }
end

def list_of_tests
  tests ||= []
  sources.map do |source|
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

describe Cucumber::Query do
  subject(:query) { described_class.new(repository) }

  let(:repository) { Cucumber::Repository.new }

  describe 'Acceptance tests for Cucumber::Query' do
    list_of_tests.each do |line_item|
      query_name = line_item.last.first
      query_proc = line_item.last.last
      cck_spec = line_item.first
      message_array = parse_ndjson_file(cck_spec).map { |msg| msg }
      it "Executes the following queries '#{query_name}' against the CCK definition provided by #{cck_spec}" do
        message_array.each { |msg| repository.update(msg) }
        name_of_file_to_check = cck_spec.sub('.ndjson', ".#{query_name}.results.json")
        expected_query_result = JSON.parse(File.read(name_of_file_to_check))

        expect(query_proc.call(query)).to eq(expected_query_result)
      end
    end
  end
end
