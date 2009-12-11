module Cucumber
  module WireSupport
    class WireStepDefinition
      def initialize(id, connection)
        @id, @connection = id, connection
      end
      
      def invoke(args)
        args = args.map do |arg|
          prepare(arg)
        end
        @connection.invoke(@id, args)
      end

      def regexp_source
        "/FIXME/"
      end

      def file_colon_line
        "FIXME:0"
      end
      
      private
      
      def prepare(arg)
        return arg unless arg.is_a?(Cucumber::Ast::Table)
        arg.to_json
      end
    end
  end
end