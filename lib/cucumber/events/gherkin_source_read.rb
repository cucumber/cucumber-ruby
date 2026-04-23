# frozen_string_literal: true

require 'cucumber/core/events'

module Cucumber
  module Events
    # Fired after we've read in the contents of a feature file
    class GherkinSourceRead
      # The path to the file
      attr_reader :path

      # The raw Gherkin source
      attr_reader :body

      # @return [Symbol] the underscored name of the class to be used as the key in an event registry
      def self.event_id
        :gherkin_source_read
      end

      def initialize(path, body)
        @path = path
        @body = body
      end

      def to_h
        {
          path: path,
          body: body
        }
      end

      def event_id
        self.class.event_id
      end
    end
  end
end
