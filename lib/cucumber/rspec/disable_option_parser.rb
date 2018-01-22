# frozen_string_literal: true

require 'optparse'

module Spec #:nodoc:
  module Runner #:nodoc:
    # Neuters RSpec's option parser.
    # (RSpec's option parser tries to parse ARGV, which
    # will fail when running cucumber)
    class OptionParser < ::OptionParser #:nodoc:
      NEUTERED_RSPEC = Object.new
      def NEUTERED_RSPEC.method_missing(_m, *_args); self; end

      def self.method_added(m)
        unless @__neutering_rspec
          @__neutering_rspec = true
          define_method(m) do |*a|
            NEUTERED_RSPEC
          end
          @__neutering_rspec = false
        end
      end
    end
  end
end
