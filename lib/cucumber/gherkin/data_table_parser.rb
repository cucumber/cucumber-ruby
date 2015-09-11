require 'gherkin3/token_scanner'
require 'gherkin3/token_matcher'

module Cucumber
  module Gherkin
    class DataTableParser
      def initialize(builder)
        @builder = builder
      end
      def parse(text)
        scanner = ::Gherkin3::TokenScanner.new(text)
        matcher = ::Gherkin3::TokenMatcher.new
        token = scanner.read
        until matcher.match_EOF(token) do
          if matcher.match_TableRow(token)
            @builder.row(token.matched_items.map { |cell_item| cell_item.text })
          end
          token = scanner.read
        end
      end
    end
  end
end
