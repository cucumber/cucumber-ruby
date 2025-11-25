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

def new_list_of_tests
  sources.flat_map do |item|
    queries.map do |key, value|
      { cck_spec: item, query_name: key, query_proc: value }
    end
  end
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

require 'cucumber/query'
require 'cucumber/messages'
require_relative '../../compatibility/support/cck/helpers'

describe Cucumber::Query do
  include CCK::Helpers

  subject(:query) { described_class.new(repository) }

  let(:repository) { Cucumber::Repository.new }

  list_of_tests.each do |test|
    describe "executes the query '#{test.last.first}' against the CCK definition '#{test.first}'" do
      let(:query_name) { test.last.first }
      let(:query_proc) { test.last.last }
      let(:cck_definition) { test.first }
      let(:cck_messages) { parse_ndjson_file(cck_definition).map.itself }
      let(:filename_to_check) { cck_definition.sub('.ndjson', ".#{query_name}.results.json") }

      before { cck_messages.each { |message| repository.update(message) } }

      it 'returns the expected query result' do
        evaluated_query = query_proc.call(query)
        expected_query_result = JSON.parse(File.read(filename_to_check))

        expect(evaluated_query).to eq(expected_query_result)
      end
    end
  end
end
