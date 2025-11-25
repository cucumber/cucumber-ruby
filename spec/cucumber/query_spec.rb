# frozen_string_literal: true

def source_names
  %w[attachments empty hooks minimal rules]
end

def sources
  source_names.map { |name| "#{Dir.pwd}/spec/support/#{name}.ndjson" }
end

def queries
  {
    'findAllPickles' => ->(query) { query.find_all_pickles.length },
    'findAllTestCases' => ->(query) { query.find_all_test_cases.length },
    'findAllTestSteps' => ->(query) { query.find_all_test_steps.length }
  }
end

def list_of_tests
  sources.flat_map do |source|
    queries.map do |query_name, query_proc|
      { cck_spec: source, query_name:, query_proc: }
    end
  end
end

require 'cucumber/query'
require 'cucumber/messages'
require_relative '../../compatibility/support/cck/helpers'

describe Cucumber::Query do
  include CCK::Helpers

  subject(:query) { described_class.new(repository) }

  let(:repository) { Cucumber::Repository.new }

  list_of_tests.each do |test|
    describe "executes the query '#{test[:query_name]}' against the CCK definition '#{test[:cck_spec]}'" do
      let(:cck_messages) { parse_ndjson_file(test[:cck_spec]).map.itself }
      let(:filename_to_check) { test[:cck_spec].sub('.ndjson', ".#{test[:query_name]}.results.json") }

      before { cck_messages.each { |message| repository.update(message) } }

      it 'returns the expected query result' do
        evaluated_query = test[:query_proc].call(query)
        expected_query_result = JSON.parse(File.read(filename_to_check))

        expect(evaluated_query).to eq(expected_query_result)
      end
    end
  end
end
