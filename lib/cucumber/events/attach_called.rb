# frozen_string_literal: true

module Cucumber
  module Events
    # Fired when attach is called in a step definition
    class AttachCalled < Core::Event.new(:src, :media_type, :filename)
      # The attachment body
      attr_reader :src

      # The content media type
      attr_reader :media_type

      # An optional filename
      attr_reader :filename

      def self.event_id
        :attach_called
      end

      def initialize(src, media_type, filename)
        @src = src
        @media_type = media_type
        @filename = filename
        super()
      end
    end
  end
end
