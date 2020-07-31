require 'cucumber/term/ansicolor'

module Cucumber
  module Term
    module Banner
      include Term::ANSIColor

      def display_banner(text, io)
        lines = text.split("\n")
        longest_line_length = lines.map(&:length).max

        io.puts cyan("┌#{'─' * (longest_line_length + 2)}┐")
        lines.map do |line|
          padding = ' ' * (longest_line_length - line.length)
          io.puts "#{cyan('│')} #{line}#{padding} #{cyan('│')}"
        end
        io.puts cyan("└#{'─' * (longest_line_length + 2)}┘")
      end
    end
  end
end
