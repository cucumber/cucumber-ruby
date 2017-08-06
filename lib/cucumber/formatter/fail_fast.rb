# frozen_string_literal: true
require 'cucumber/formatter/io'
require 'cucumber/formatter/console'

module Cucumber
  module Formatter

    class FailFast

      def initialize(configuration)
        configuration.on_event :test_case_finished do |event|
          _test_case, result = *event.attributes
          Cucumber.wants_to_quit = true unless result.ok?(configuration.strict)
        end
      end

    end

  end
end
