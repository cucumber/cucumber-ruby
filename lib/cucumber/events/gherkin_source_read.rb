# frozen_string_literal: true

module Cucumber
  module Events
    # Fired after we've read in the contents of a feature file
    class GherkinSourceRead < Base
      # The path to the file
      attr_reader :path

      # The raw Gherkin source
      attr_reader :body

      def self.event_id
        :gherkin_source_read
      end

      def initialize(path, body)
        @path = path
        @body = body
        super()
      end
    end
  end
end
