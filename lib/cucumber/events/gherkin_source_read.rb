require 'cucumber/core/events'

module Cucumber
  module Events

    # Fired after we've read the source of a feature file
    class GherkinSourceRead < Core::Event.new(:path, :source)

      # The path to the feature file
      attr_reader :path

      # The Gherkin source
      attr_reader :source
    end

  end
end
