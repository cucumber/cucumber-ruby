module Cucumber
  module Filters

    class Quit
      def initialize(receiver)
        @receiver = receiver
      end

      def test_case(test_case)
        unless Cucumber.wants_to_quit
          test_case.describe_to @receiver
        end
        self
      end

      def done
        @receiver.done
        self
      end
    end

  end
end

