# frozen_string_literal: true

module Cucumber
  module Formatter
    # Common Message Handlers to be used across all message-based formatters
    # Designed to work solely with events of type `Envelope`
    module MessageHandlers
      def store_current_test_run_hook_started_id(event)
        @current_test_run_hook_started_id = event.envelope.test_run_hook_started.id if event.envelope.test_run_hook_started
      end
    end
  end
end
