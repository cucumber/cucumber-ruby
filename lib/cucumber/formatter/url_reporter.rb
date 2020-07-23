require 'cucumber/term/ansicolor'

module Cucumber
  module Formatter
    class URLReporter
      include Term::ANSIColor

      def initialize(io)
        @io = io
      end

      def report(url)
        uri = URI(url)
        path_length = uri.path.length
        @io.puts blue("┌─────────────────────────────#{'─' * path_length}┐")
        @io.puts "#{blue('│')} View your report at:        #{' ' * path_length}#{blue('│')}"
        @io.puts "#{blue('│')} https://reports.cucumber.io#{uri.path} #{blue('│')}"
        @io.puts blue("└─────────────────────────────#{'─' * path_length}┘")
      end
    end
  end
end
