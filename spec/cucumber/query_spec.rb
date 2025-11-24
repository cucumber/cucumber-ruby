# frozen_string_literal: true

def sources
  %W[
    #{Dir.pwd}/spec/support/attachments.ndjson
    #{Dir.pwd}/spec/support/empty.ndjson
    #{Dir.pwd}/spec/support/hooks.ndjson
    #{Dir.pwd}/spec/support/minimal.ndjson
    #{Dir.pwd}/spec/support/rules.ndjson
  ]
end

def queries
  {
    'findAllPickles' => ->(query) { query.find_all_pickles.length }
  }
end

def list_of_tests
  tests ||= []
  sources.map do |source|
    queries.each do |query|
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
    list_of_tests.each do |test|
      query_name = test.last.first
      query_proc = test.last.last
      cck_definition = test.first
      message_array = parse_ndjson_file(cck_definition).map.itself
      it "Executes the query '#{query_name}' against the CCK definition '#{cck_definition}'" do
        message_array.each { |message| repository.update(message) }
        name_of_file_to_check = cck_definition.sub('.ndjson', ".#{query_name}.results.json")
        expected_query_result = JSON.parse(File.read(name_of_file_to_check))

        expect(query_proc.call(query)).to eq(expected_query_result)
      end
    end
  end
end
