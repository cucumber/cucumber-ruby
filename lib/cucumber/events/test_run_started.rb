module Cucumber
  module Events

    # Fired at the very beginning of a test run
    class TestRunStarted

      # The configuration for the run
      attr_reader :configuation

      # @private
      def initialize(configuration)
        @configuration = configuration
      end

    end

  end
end
