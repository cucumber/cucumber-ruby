module Cucumber
  module TreetopParser
    module Feature
      class SyntaxError < StandardError
        def initialize(file, parser)
          tf = parser.terminal_failures
          expected = tf.size == 1 ? tf[0].expected_string : "one of #{tf.map{|f| f.expected_string}.uniq*', '}"
          @message = "#{file}:#{parser.failure_line}: Parse error, expected #{expected}"
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
          feature = ast.feature
          feature.file = file
          feature
        end
      end      
    end
  end
end