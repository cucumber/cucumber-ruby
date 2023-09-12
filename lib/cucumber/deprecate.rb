# frozen_string_literal: true

require 'cucumber/platform'
require 'cucumber/gherkin/formatter/ansi_escapes'

module Cucumber
  module Deprecate
    class AnsiString
      def failure_message(message)
        "\e[31m" + message + "\e[0m"
      end
    end
  end

  def self.deprecate(message, method, remove_after_version)
    $stderr.puts Deprecate::AnsiString.new.failure_message(
      "\nWARNING: ##{method} is deprecated" \
        " and will be removed after version #{remove_after_version}. #{message}.\n" \
        "(Called from #{caller(3..3).first})"
    )
  end
end
