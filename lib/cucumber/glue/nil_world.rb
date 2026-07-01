# frozen_string_literal: true

module Cucumber
  module Glue
    # Raised if a World block returns Nil.
    class NilWorld < StandardError
      def initialize
        super('World procs should never return nil')
      end
    end
  end
end
