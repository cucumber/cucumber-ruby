module Cucumber
  module Formatter
    class URLReporter
      def report(url)
        uri = URI(url)
        puts "View your report at https://reports.cucumber.io#{uri.path}"
      end
    end
  end
end