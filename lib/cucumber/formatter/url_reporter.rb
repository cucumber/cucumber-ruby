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
        @io.puts cyan("┌─────────────────────────────#{'─' * path_length}┐")
        @io.puts "#{cyan('│')} View your Cucumber Report at:#{' ' * (path_length-1)}#{cyan('│')}"
        @io.puts "#{cyan('│')} https://reports.cucumber.io#{uri.path} #{cyan('│')}"
        @io.puts cyan("└─────────────────────────────#{'─' * path_length}┘")
      end
    end
  end
end
