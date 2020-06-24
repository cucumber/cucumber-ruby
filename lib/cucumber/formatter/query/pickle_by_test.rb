require 'cucumber/formatter/errors'

module Cucumber
  module Formatter
    module Query
      class PickleByTest
        def initialize(config)
          @pickle_id_by_test_case_id = {}
          @pickle_by_id = {}

          config.on_event :envelope, &method(:on_envelope)
          config.on_event :test_case_created, &method(:on_test_case_created)
        end

        def pickle_id(test_case)
          return @pickle_id_by_test_case_id[test_case.id] if @pickle_id_by_test_case_id.key?(test_case.id)

          raise TestCaseUnknownError, "No pickle found for #{test_case.id} }. Known: #{@pickle_id_by_test_case_id.keys}"
        end

        def pickle(test_case)
          @pickle_by_id[pickle_id(test_case)]
        end

        private

        def on_envelope(event)
          return unless event.envelope.pickle

          @pickle_by_id[event.envelope.pickle.id] = event.envelope.pickle
        end

        def on_test_case_created(event)
          @pickle_id_by_test_case_id[event.test_case.id] = event.pickle.id
        end
      end
    end
  end
end
