# frozen_string_literal: true

require 'digest/sha2'

module Cucumber
  module Filters
    # Reverses the order of test cases
    class Reverser
      attr_reader :seed
      private :seed

      def initialize(receiver = nil)
        @receiver = receiver
        @test_cases = []
      end

      def test_case(test_case)
        @test_cases << test_case
        self
      end

      def done
        reversed_test_cases.each do |test_case|
          test_case.describe_to(@receiver)
        end
        @receiver.done
        self
      end

      def with_receiver(receiver)
        self.class.new(receiver)
      end

      private

      def reversed_test_cases
        @test_cases.reverse
      end
    end
  end
end
