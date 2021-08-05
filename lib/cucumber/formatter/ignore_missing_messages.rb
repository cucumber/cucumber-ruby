# frozen_string_literal: true

module Cucumber
  module Formatter
    class IgnoreMissingMessages < BasicObject
      def initialize(receiver)
        @receiver = receiver
      end

      def method_missing(message, *args)
        @receiver.respond_to?(message) ? @receiver.send(message, *args) : super
      end

      # rubocop:disable Lint/MissingSuper
      def respond_to_missing?(name, include_private = false)
        @receiver.respond_to?(name, include_private)
      end
      # rubocop:enable Lint/MissingSuper
    end
  end
end
