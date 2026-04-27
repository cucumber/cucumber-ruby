# frozen_string_literal: true

require_relative 'base'

module Cucumber
  module Events
    class Envelope < Base
      attr_reader :envelope

      # The underscored name of the class to be used as the key in an event registry
      #   @return [Symbol]
      def self.event_id
        :envelope
      end

      def initialize(envelope)
        @envelope = envelope
        super()
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
