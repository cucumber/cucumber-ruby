require 'cucumber/formatter/gherkin_formatter_adapter'
require 'cucumber/formatter/io'
require 'gherkin/formatter/argument'
require 'gherkin/formatter/json_formatter'

module Cucumber
  module Formatter
    # The formatter used for <tt>--format json</tt>
    class Json < GherkinFormatterAdapter
      include Io

      def initialize(runtime, io, options)
        @io = ensure_io(io, "json")
        @formatter = Gherkin::Formatter::JSONFormatter.new(@io)
        super(@formatter, false)
      end

      def embed(src, mime_type, label)
        @formatter.embedding(mime_type, {'label' => label, 'src' => src}.to_json)
      end
    end
  end
end

