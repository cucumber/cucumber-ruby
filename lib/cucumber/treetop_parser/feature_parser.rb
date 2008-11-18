module Cucumber
  module TreetopParser
    module Feature
      class SyntaxError < StandardError
        def initialize(file, parser)
          tf = parser.terminal_failures
          expected = tf.size == 1 ? tf[0].expected_string.inspect : "one of #{tf.map{|f| f.expected_string.inspect}.uniq*', '}"
          after = parser.input[parser.index...parser.failure_index]
          found = parser.input[parser.failure_index..parser.failure_index]
          @message = "#{file}:#{parser.failure_line}:#{parser.failure_column}: Parse error, expected #{expected}. After #{after.inspect}. Found: #{found.inspect}"
        end
        
        def message
          @message
        end
      end
      
      class << self
        attr_accessor :last_scenario
      end
      
      def parse_feature(file)
        ast = parse(IO.read(file))
        if ast.nil?
          raise SyntaxError.new(file, self)
        else
          feature = ast.compile
          feature.file = file
          feature
        end
      end      
    end
  end
end