# frozen_string_literal: true

require 'cucumber/core/events'

module Cucumber
  module Events
    # Fired after we've parsed the contents of a feature file
    class GherkinSourceParsed < BaseEventNew
      # # The Gherkin Ast
      attr_reader :gherkin_document

      # The underscored name of the class to be used as the key in an event registry
      #   @return [Symbol]
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
