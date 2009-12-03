module Cucumber
  module WireSupport
    class WireStepDefinition
      def initialize(id, connection)
        @id, @connection = id, connection
      end
      
      def invoke(args)
        args = args.map do |arg|
          if arg.is_a?(Cucumber::Ast::Table)
            arg.raw
          else
            arg
          end
        end
        @connection.invoke(@id, args)
      end

      def regexp_source
        "/FIXME/"
      end

      def file_colon_line
        "FIXME:0"
      end
    end
  end
end