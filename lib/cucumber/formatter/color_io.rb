require 'forwardable'

module Cucumber
  module Formatter
    # Adapter to make #puts/#print/#flush work with colours on Windows
    class ColorIO
      extend Forwardable
      def_delegators :@kernel, :puts, :print # win32console colours only work when sent to Kernel
      def_delegators :@stdout, :flush, :tty?

      def initialize
        @kernel = Kernel
        @stdout = STDOUT
      end
    end
  end
end