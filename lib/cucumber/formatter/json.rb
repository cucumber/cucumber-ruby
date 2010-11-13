require 'cucumber/formatter/gherkin_formatter_adapter'
require 'cucumber/formatter/io'
require 'gherkin/formatter/argument'
require 'gherkin/formatter/json_formatter'

module Cucumber
  module Formatter
    # The formatter used for <tt>--format json</tt>
    class Json < GherkinFormatterAdapter
      include Io

      def initialize(step_mother, io, options)
        @io = ensure_io(io, "json")
        @obj = {'features' => []}
        super(Gherkin::Formatter::JSONFormatter.new(nil), false)
      end

      def after_feature(feature)
        super
        @obj['features'] << @gf.gherkin_object
      end

      def after_features(features)
        @io.write(@obj.to_json)
      end
    end
  end
end

