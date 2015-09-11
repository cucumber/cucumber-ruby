require 'cucumber/formatter/io'
require 'cucumber/formatter/console'

module Cucumber
  module Formatter
    class FailFast
      def initialize(configuration)
        @configuration = configuration
      end

      def after_test_case(test_case, result)
        Cucumber.wants_to_quit = true unless result.ok? @configuration.strict?
      end

      def done; end
      def before_test_case *args; end
      def before_test_step *args; end
      def after_test_step *args; end
    end
  end
end