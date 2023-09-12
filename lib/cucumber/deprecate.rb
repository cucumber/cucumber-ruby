# frozen_string_literal: true

require 'cucumber/platform'
require 'cucumber/gherkin/formatter/ansi_escapes'

module Cucumber
  module Deprecate
    class AnsiString
      def self.failure_message(message)
        AnsiString.new.failure_message(message)
      end

      def failure_message(message)
        failed + message + reset
      end
    end

    module ForUsers
      def self.call(message, method, remove_after_version)
        $stderr.puts AnsiString.failure_message(
          "\nWARNING: ##{method} is deprecated" \
          " and will be removed after version #{remove_after_version}. #{message}.\n" \
          "(Called from #{caller(3..3).first})"
        )
      end
    end
  end

  def self.deprecate(*args)
    ForUsers.call(*args)
  end
end
