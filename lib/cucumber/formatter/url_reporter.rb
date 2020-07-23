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
        @io.puts "┌─────────────────────────────#{'─' * path_length}┐"
        @io.puts "│ View your report at:        #{' ' * path_length}│"
        @io.puts "│ https://reports.cucumber.io#{uri.path} │"
        @io.puts "└─────────────────────────────#{'─' * path_length}┘"
      end
    end
  end
end
