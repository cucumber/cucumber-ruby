module Cucumber
  module WireSupport
    class WireStepDefinition
      attr_reader :regexp_source, :file_colon_line

      def initialize(connection, data)
        @connection = connection
        @id              = data['id']
        @regexp_source   = data['regexp'] || "Unknown"
        @file_colon_line = data['source'] || "Unknown"
      end

      def invoke(args)
        @connection.invoke(@id, args)
      end

    end
  end
end
