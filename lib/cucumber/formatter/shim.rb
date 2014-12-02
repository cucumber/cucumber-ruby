require 'cucumber/formatter/fanout'

module Cucumber
  module Formatter
    module Shim

      def self.for(factory)
        return Legacy unless factory.respond_to?(:formatter_api_shim)
        factory.formatter_api_shim
      end

      class Legacy
        def self.wrap(formatter, results, support_code, configuration)
          LegacyApi::Adapter.new(
            Formatter::IgnoreMissingMessages.new(formatter),
            results, support_code, configuration)
        end
      end

      class Mixed
        def self.wrap(formatter, results, support_code, configuration)
          Fanout.new(
            [
              formatter,
              Legacy.wrap(formatter, results, support_code, configuration)
            ]
          )
        end
      end

      class None
        def self.wrap(formatter, results, support_code, configuration)
          formatter
        end
      end
    end
  end
end
