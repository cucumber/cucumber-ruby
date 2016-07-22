# frozen_string_literal: true
module Cucumber
  module Formatter

    class IgnoreMissingMessages < BasicObject
      def initialize(receiver)
        @receiver = receiver
      end

      def method_missing(message, *args)
        @receiver.send(message, *args) if @receiver.respond_to?(message)
      end

      def respond_to_missing?(name, include_private = false)
        @receiver.respond_to?(name, include_private)
      end
    end

  end
end

