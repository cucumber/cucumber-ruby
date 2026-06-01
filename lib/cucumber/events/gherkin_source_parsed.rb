# frozen_string_literal: true

require_relative 'base'

module Cucumber
  module Events
    # Fired after we've parsed the contents of a feature file
    class GherkinSourceParsed < Base
      # # The Gherkin Ast
      attr_reader :gherkin_document

      def self.event_id
        :gherkin_source_parsed
      end

      def initialize(gherkin_document)
        @gherkin_document = gherkin_document
        super()
      end
    end
  end
end
