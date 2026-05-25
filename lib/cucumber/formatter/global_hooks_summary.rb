# frozen_string_literal: true

require 'cucumber/formatter/io'
require 'cucumber/formatter/console'
require 'cucumber/formatter/console_counts'
require 'cucumber/formatter/console_issues'
require 'cucumber/core/test/result'
require 'cucumber/formatter/ast_lookup'

module Cucumber
  module Formatter
    # AllHookSummary formatter, keep track of failures in Before/AfterAll hooks
    class GlobalHooksSummary
      include Console

      def initialize(config)
        @config = config
        @all_hook_failures = []

        @config.on_event :test_run_hook_finished do |event|
          @all_hook_failures << event unless event.test_result.ok?
        end
      end

      def ok?
        @all_hook_failures.empty?
      end

      def exception_listing
        [format_string('Global hook failures:', :failed)] + @all_hook_failures.map do |event|
          format_string("#{event.hook.location} # #{event.test_result.exception} (#{event.test_result.exception.class})", :failed)
        end
      end
    end
  end
end
