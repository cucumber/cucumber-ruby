module Cucumber
  module Parser
    class StoryParser < Treetop::Runtime::CompiledParser
      def compile_error(file)
        tf = terminal_failures
        expected = tf.size == 1 ? tf[0].expected_string : "one of #{tf.map{|f| f.expected_string}.uniq*', '}"
        "#{file}:#{failure_line}: Parse error, expected #{expected}"
      end
    end
  end
end