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
            [["https://reports.cucumber.io#{uri.path}", :cyan, :bold, :underline]],
            '',
            [['This report will self-destruct in 24h unless it is claimed or deleted.', :green, :bold]]
          ],
          @io
        )
      end
    end
  end
end
