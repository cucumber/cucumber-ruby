module Cucumber
  module Parser
    module FileParser
      FILE_LINE_PATTERN = /^([\w\W]*?):([\d:]+)$/

      # Parses a file and returns a Cucumber::Ast
      def parse_file(file)
        _, path, lines = *FILE_LINE_PATTERN.match(file)
        if path
          lines = lines.split(':').map { |line| line.to_i }
        else
          path = file
          lines = []
        end

        feature = File.open(path, Cucumber.file_mode('r')) do |io|
          parse_or_fail(io.read, path)
        end
        feature.lines = lines
        feature
      end
      
      def parse_or_fail(s, file=nil)
        parse_tree = parse(s)
        if parse_tree.nil?
          raise SyntaxError.new(file, self)
        else
          ast = parse_tree.build
          ast.file = file
          ast
        end
      end
    end

    class SyntaxError < StandardError
      def initialize(file, parser)
        tf = parser.terminal_failures
        expected = tf.size == 1 ? tf[0].expected_string.inspect : "one of #{tf.map{|f| f.expected_string.inspect}.uniq*', '}"
        after = parser.input[parser.index...parser.failure_index]
        found = parser.input[parser.failure_index..parser.failure_index]
        @message = "#{file}:#{parser.failure_line}:#{parser.failure_column}: " +
          "Parse error, expected #{expected}. After #{after.inspect}. Found: #{found.inspect}"
      end

      def message
        @message
      end
    end
  end
end