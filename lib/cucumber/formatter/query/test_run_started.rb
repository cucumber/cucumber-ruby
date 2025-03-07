# frozen_string_literal: true

require 'cucumber/formatter/errors'

module Cucumber
  module Formatter
    module Query
      class TestRunStarted
        def initialize(config)
          @test_run_ids = {}
          config.on_event :test_run_started, &method(:on_test_run_started)
        end

        def test_run_id(test_case)
          return @test_run_ids[test_case.id] if @test_run_ids.key?(test_case.id)

          raise TestCaseUnknownError, "No pickle found for #{test_case.id} }. Known: #{@test_run_ids.keys}"
        end

        private

        def on_test_run_started(event)
          @test_run_ids[event.test_case.id] = event.pickle.id
        end
      end
    end
  end
end
