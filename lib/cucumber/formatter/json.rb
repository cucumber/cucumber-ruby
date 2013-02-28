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
        super(Gherkin::Formatter::JSONFormatter.new(@io), false)
      end
    end
  end
end

