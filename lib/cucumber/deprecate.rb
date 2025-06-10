# frozen_string_literal: true

require 'cucumber/platform'
require 'cucumber/gherkin/formatter/ansi_escapes'

module Cucumber
  def self.deprecate(message, method, remove_after_version)
    $stderr.puts(
      "\nWARNING: #{method} is deprecated" \
        " and will be removed after version #{remove_after_version}. #{message}.\n" \
        "(Called from #{caller(3..3).first})"
    )
  end
end
