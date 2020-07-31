require 'cucumber/term/ansicolor'

module Cucumber
  module Term
    module Banner
      def display_banner(lines, io)
        BannerMaker.new.display_banner(lines, io)
      end

      class BannerMaker
        include Term::ANSIColor

        def display_banner(lines, io)
          lines = lines.split("\n") if lines.is_a? String
          longest_line_length = lines.map { |line| line_length(line) }.max

          io.puts cyan("┌#{'─' * (longest_line_length + 2)}┐")
          lines.map do |line|
            padding = ' ' * (longest_line_length - line_length(line))
            io.puts "#{cyan('│')} #{display_line(line)}#{padding} #{cyan('│')}"
          end
          io.puts cyan("└#{'─' * (longest_line_length + 2)}┘")
        end

        private

        def display_line(line)
          line.is_a?(Array) ? line.map { |span| display_span(span) }.join : line
        end

        def display_span(span)
          if span.is_a?(Array)
            display = span.shift
            span.each { |modifier| display = send(modifier, display) }
            return display
          end
          span
        end

        def line_length(line)
          if line.is_a?(Array)
            length = 0
            line.each { |span| length += span_length(span) }
            return length
          end

          line.length
        end

        def span_length(span)
          span.is_a?(Array) ? span[0].length : span.length
        end
      end
    end
  end
end
