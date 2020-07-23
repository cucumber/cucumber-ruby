module Cucumber
  module Formatter
    class URLReporter
      def report(url)
        uri = URI(url)
        path_length = uri.path.length
        puts <<-EOM
┌─────────────────────────────#{'─' * path_length}┐
│ View your report at:        #{' ' * path_length}│
│ https://reports.cucumber.io#{uri.path} │
└─────────────────────────────#{'─' * path_length}┘
EOM
      end
    end
  end
end
