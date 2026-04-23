# frozen_string_literal: require_relative 'base_event_new'

module Cucumber
  module Events
    # Fired after we've parsed the contents of a feature file
    class GherkinSourceParsed < BaseEventNew
      # # The Gherkin Ast
      attr_reader :gherkin_document

      # The underscored name of the class to be used as the key in an event registry
      #   @return [Symb
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
