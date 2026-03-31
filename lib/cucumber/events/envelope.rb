# frozen_string_literal: true

require 'cucumber/core/events'

module Cucumber
  module Events
    class Envelope < Core::Event.new(:envelope)
      attr_reader :envelope

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
