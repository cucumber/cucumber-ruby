# frozen_string_literal: true

require_relative 'keys_checker'
require_relative 'helpers'

module CCK
  class MessagesComparator
    include Helpers

    def initialize(detected, expected)
      compare(detected, expected)
    end

    def errors
      all_errors.flatten
    end

    private

    def compare(detected, expected)
      detected_by_type = messages_by_type(detected)
      expected_by_type = messages_by_type(expected)

      detected_by_type.each_key do |type|
        compare_list(detected_by_type[type], expected_by_type[type])
      rescue StandardError => e
        all_errors << "Error while comparing #{type}: #{e.message}"
      end
    end

    def messages_by_type(messages)
      by_type = Hash.new { |h, k| h[k] = [] }
      messages.each do |msg|
        by_type[message_type(msg)] << remove_envelope(msg)
      end
      by_type
    end

    def remove_envelope(message)
      message.send(message_type(message))
    end

    def compare_list(detected, expected)
      detected.each_with_index do |message, index|
        compare_message(message, expected[index])
      end
    end

    def compare_message(detected, expected)
      return if not_message?(detected)
      return if ignorable?(detected)
      return if incomparable?(detected)

      all_errors << CCK::KeysChecker.compare(detected, expected)
      compare_sub_messages(detected, expected)
    end

    def not_message?(detected)
      !detected.is_a?(Cucumber::Messages::Message)
    end

    # These messages need to be ignored because they are too large, or they feature timestamps which will be different
    def ignorable?(detected)
      too_large_message?(detected) || time_message?(detected)
    end

    def too_large_message?(detected)
      detected.is_a?(Cucumber::Messages::GherkinDocument) || detected.is_a?(Cucumber::Messages::Pickle)
    end

    def time_message?(detected)
      detected.is_a?(Cucumber::Messages::Timestamp) || detected.is_a?(Cucumber::Messages::Duration)
    end

    # These messages need to be ignored because they are often not of identical shape
    def incomparable?(detected)
      detected.is_a?(Cucumber::Messages::Ci) || detected.is_a?(Cucumber::Messages::Git)
    end

    def compare_sub_messages(detected, expected)
      return unless expected.respond_to? :to_h

      expected.to_h.each_key do |key|
        value = expected.send(key)
        if value.is_a?(Array)
          compare_list(detected.send(key), value)
        else
          compare_message(detected.send(key), value)
        end
      end
    end

    def all_errors
      @all_errors ||= []
    end
  end
end
