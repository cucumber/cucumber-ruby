# frozen_string_literal: true

require 'cucumber/core/events'

module Cucumber
  module Events
    # Fired after we've parsed the contents of a feature file
    class GherkinSourceParsed
      # # The Gherkin Ast
      attr_reader :gherkin_document

      # @return [Symbol] the underscored name of the class to be used as the key in an event registry
      def self.event_id
        :gherkin_source_parsed
      end

      def initialize(gherkin_document)
        @gherkin_document = gherkin_document
      end

      def to_h
        {
          gherkin_document: gherkin_document
        }
      end

      def event_id
        self.class.event_id
      end
    end
  end
end
