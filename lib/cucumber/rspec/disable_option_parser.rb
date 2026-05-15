# frozen_string_literal: true

require 'optparse'

module Spec
  module Runner
    # Neuters RSpec's option parser.
    # (RSpec's option parser tries to parse ARGV, which
    # will fail when running cucumber)
    class OptionParser < ::OptionParser
      NEUTERED_RSPEC = Object.new
      def NEUTERED_RSPEC.method_missing(_method, *_args) # rubocop:disable Style/MissingRespondToMissing
        self || super
      end

      def self.method_added(method)
        return if @__neutering_rspec

        @__neutering_rspec = true
        define_method(method) do |*_a|
          NEUTERED_RSPEC
        end
        @__neutering_rspec = false

        super
      end
    end
  end
end
