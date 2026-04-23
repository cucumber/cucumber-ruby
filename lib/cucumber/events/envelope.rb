# frozen_string_literal: true

require 'cucumber/core/events'

module Cucumber
  module Events
    class Envelope
      attr_reader :envelope

      # @return [Symbol] the underscored name of the class to be used as the key in an event registry
      def self.event_id
        :envelope
      end

      def initialize(envelope)
        @envelope = envelope
      end

      def to_h
        {
          envelope: envelope
        }
      end

      def event_id
        self.class.event_id
      end

      def inspect
        "Envelope Event -> Message Type: #{type}}"
      end

      def to_s
        inspect
      end

      private

      def type
        envelope.instance_variables.detect { |message| !envelope.send(name_of(message)).nil? }
      end

      def name_of(message)
        message.to_s.delete('@')
      end
    end
  end
end
