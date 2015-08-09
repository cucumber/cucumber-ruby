require 'cucumber/core/ast/location'

module Cucumber
  module WireSupport
    class WireStepDefinition
      attr_reader :regexp_source, :location

      def initialize(connection, data)
        @connection = connection
        @id              = data['id']
        @regexp_source   = data['regexp'] || "Unknown"
        @location = data['source'] ? Cucumber::Core::Ast::Location.from_file_colon_line(data['source']) : Cucumber::Core::Ast::Location.new("Unknown")
      end

      def invoke(args)
        @connection.invoke(@id, args)
      end

    end
  end
end
