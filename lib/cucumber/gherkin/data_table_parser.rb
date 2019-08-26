# frozen_string_literal: true

require 'gherkin/gherkin'
require 'gherkin/dialect'

module Cucumber
  module Gherkin
    class DataTableParser
      def initialize(builder)
        @builder = builder
      end

      def parse(text)
        gherkin_document = nil
        messages = ::Gherkin::Gherkin.from_source('dummy', feature_header + text, include_source: false, include_pickles: false)
        messages.each do |message|
          gherkin_document = message.gherkinDocument.to_hash unless message.gherkinDocument.nil?
        end

        return if gherkin_document.nil?
        gherkin_document[:feature][:children][0][:scenario][:steps][0][:data_table][:rows].each do |row|
          @builder.row(row[:cells].map { |cell| cell[:value] })
        end
      end

      def feature_header
        dialect = ::Gherkin::Dialect.for('en')
        %(#{dialect.feature_keywords[0]}:
            #{dialect.scenario_keywords[0]}:
              #{dialect.given_keywords[0]} x
         )
      end
    end
  end
end
