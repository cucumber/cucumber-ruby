# frozen_string_literal: true

require 'cucumber/platform'
require 'cucumber/gherkin/formatter/ansi_escapes'

module Cucumber
  module Deprecate
    class AnsiString
      def failure_message(message)
        failed + message + reset
      end
    end

    module ForUsers
      def self.call(message, method, remove_after_version)
        $stderr.puts AnsiString.new.failure_message(
          "\nWARNING: ##{method} is deprecated" \
          " and will be removed after version #{remove_after_version}. #{message}.\n" \
          "(Called from #{caller(3..3).first})"
        )
      end
    end
  end

  def self.deprecate(message, method, remove_after_version)
    ForUsers.call(message, method, remove_after_version)
  end
end
