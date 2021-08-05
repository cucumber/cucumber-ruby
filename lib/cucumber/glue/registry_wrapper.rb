# frozen_string_literal: true

module Cucumber
  module Glue
    class RegistryWrapper
      def initialize(registry)
        @registry = registry
      end

      def create_expression(string_or_regexp)
        @registry.create_expression(string_or_regexp)
      end

      def current_world
        @registry.current_world
      end
    end
  end
end
