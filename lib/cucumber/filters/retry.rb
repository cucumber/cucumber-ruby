require 'cucumber/core/filter'
require 'cucumber/running_test_case'
require 'cucumber/events/bus'
require 'cucumber/events/after_test_case'

module Cucumber
  module Filters
    class Retry < Core::Filter.new(:configuration)

      def test_case(test_case)
        super 

        configuration.on_event(:after_test_case) do |event|
          test_case.describe_to(receiver) if event.result.failed?
        end
      end
    end
  end
end