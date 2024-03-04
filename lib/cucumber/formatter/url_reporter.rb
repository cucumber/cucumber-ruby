# frozen_string_literal: true

module Cucumber
  module Formatter
    class URLReporter
      def initialize(io)
        @io = io
      end

      def report(banner)
        @io.puts(banner)
      end
    end

    class NoReporter
      def report(_banner); end
    end
  end
end
