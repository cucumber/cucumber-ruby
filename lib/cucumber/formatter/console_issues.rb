require 'cucumber/formatter/console'

module Cucumber
  module Formatter
    class ConsoleIssues
      include Console

      def initialize(config)
        @failures = []
        @config = config
        @config.on_event(:test_case_finished) do |event|
          @failures << event.test_case if event.result.failed?
        end
      end

      def to_s
        return if @failures.empty?
        result = [ format_string("Failing Scenarios:", :failed) ] + @failures.map { |failure|
          source = @config.source? ? format_string(" # #{failure.keyword}: #{failure.name}", :comment) : ''
          format_string("cucumber #{profiles_string}" + failure.location, :failed) + source
        }
        result.join("\n")
      end

      def any?
        @failures.any?
      end

      private

      def profiles_string
        return if @config.custom_profiles.empty?
        @config.custom_profiles.map { |profile| "-p #{profile}" }.join(' ') + ' '
      end
    end
  end
end
