module Cucumber
  module Formatter
    class TestPickleFinder
      def initialize(config)
        @pickle_by_test_case_id = {}
        config.on_event :test_case_created, &method(:on_test_case_created)
      end

      def pickle_id(test_case)
        @pickle_by_test_case_id[test_case.id]
      end

      private

      def on_test_case_created(event)
        @pickle_by_test_case_id[event.test_case.id] = event.pickle.id
      end
    end
  end
end