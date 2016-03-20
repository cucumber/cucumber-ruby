module Cucumber
  module Events

    # Fired after we've read the source of a feature file
    class GherkinSourceRead

      # The path to the feature file
      attr_reader :path

      # The Gherkin source
      attr_reader :source

      # @private
      def initialize(path, source)
        @path, @source = path, source
      end
    end

  end
end
