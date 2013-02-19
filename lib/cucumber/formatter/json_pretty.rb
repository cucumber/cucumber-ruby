require 'multi_json'
require 'cucumber/formatter/json'

module Cucumber
  module Formatter
    # The formatter used for <tt>--format json_pretty</tt>
    class JsonPretty < Json
      def after_features(features)
        @io.write(MultiJson.dump(@obj, :pretty => true))
      end
    end
  end
end

