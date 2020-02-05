require 'cucumber/formatter/errors'

module Cucumber
  module Formatter
    module Query
      class TestCaseStartedByTestCase
        def initialize(config)
          @config = config
          config.on_event :test_case_created, &method(:on_test_case_created)
          config.on_event :test_case_started, &method(:on_test_case_started)

          @attempts_by_test_case_id = {}
        end

        def attempt_by_test_case(test_case)
          raise TestCaseUnknownError, "No test case found for #{test_case.id} }. Known: #{@attempts_by_test_case_id.keys}" unless @attempts_by_test_case_id.key?(test_case.id)
          @attempts_by_test_case_id[test_case.id]
        end

        private

        def on_test_case_created(event)
          @attempts_by_test_case_id[event.test_case.id] = 0
        end

        def on_test_case_started(event)
          @attempts_by_test_case_id[event.test_case.id] += 1
        end
      end
    end
  end
end
