# frozen_string_literal: true

require 'gherkin/gherkin'
require 'gherkin/dialect'

module Cucumber
  module Gherkin
    class StepsParser
      def initialize(builder, language)
        @builder = builder
        @language = language
      end

      def parse(text)
        dialect = ::Gherkin::Dialect.for(@language)
        gherkin_document = nil
        messages = ::Gherkin::Gherkin.from_source('dummy', feature_header(dialect) + text, default_dialect: @language, include_source: false, include_pickles: false)
        messages.each do |message|
          gherkin_document = message.gherkinDocument.to_hash unless message.gherkinDocument.nil?
        end

        @builder.steps(gherkin_document[:feature][:children][0][:scenario][:steps])
      end

      def feature_header(dialect)
        %(#{dialect.feature_keywords[0]}:
            #{dialect.scenario_keywords[0]}:
         )
      end
    end
  end
end
