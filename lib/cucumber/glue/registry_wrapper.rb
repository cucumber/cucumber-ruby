# frozen_string_literal: true

module Cucumber
  module Glue
    ##
    # This class wraps some internals methods to expose them to external plugins.
    class RegistryWrapper
      def initialize(registry)
        @registry = registry
      end

      ##
      # Creates a new CucumberExpression from the given +string_or_regexp+.
      #
      # If +string_or_regexp+ is a string, it will return a new CucumberExpression::CucumberExpression
      #
      # If +string_or_regexp+ is a regexp, it will return a new CucumberExpressions::RegularExpression
      #
      # An ArgumentError is raised if +string_or_regexp+ is not a string or a regexp
      def create_expression(string_or_regexp)
        @registry.create_expression(string_or_regexp)
      end

      ##
      # Return the current execution environment - AKA an isntance of World
      def current_world
        @registry.current_world
      end
    end
  end
end
