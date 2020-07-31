require 'cucumber/term/banner'

module Cucumber
  module Formatter
    class URLReporter
      include Term::Banner

      def initialize(io)
        @io = io
      end

      def report(url)
        uri = URI(url)
        display_banner(
          [
            'View your Cucumber Report at:',
            [["https://reports.cucumber.io#{uri.path}", :blue, :underline]]
          ],
          @io
        )
      end
    end
  end
end
