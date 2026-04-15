# frozen_string_literal: true

require 'cucumber/core/events'

module Cucumber
  module Events
    class Envelope < Core::Event.new(:envelope)
      attr_reader :envelope

      # @return [Symbol] the underscored name of the class to be used as the key in an event registry
      def self.event_id
        underscore(name.split('::').last).to_sym
      end

      def self.underscore(string)
        string
          .to_s
          .gsub('::', '/')
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-', '_')
          .downcase
      end

      def self.new(*events)
        # Use normal constructor for subclasses of Event
        return super if ancestors.index(Event).positive?

        Class.new(Event) do
          # NB: We need to use metaprogramming here instead of direct variable obtainment
          # because JRuby does not guarantee the order in which variables are defined is equivalent
          # to the order in which they are obtainable
          #
          # See https://github.com/jruby/jruby/issues/7988 for more info
          attr_reader(*events)

          define_method(:initialize) do |*attributes|
            events.zip(attributes) do |name, value|
              instance_variable_set(:"@#{name}", value)
            end
          end

          define_method(:attributes) do
            events.map { |var| instance_variable_get(:"@#{var}") }
          end

          define_method(:to_h) do
            events.zip(attributes).to_h
          end

          def event_id
            self.class.event_id
          end
        end
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
