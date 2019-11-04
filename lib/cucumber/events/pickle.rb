# frozen_string_literal: true

require 'cucumber/core/events'

module Cucumber
  module Events
    # Event fired after each pickle is compiled.
    class Pickle < Core::Event.new(:pickle, :test_case)
      # @return Cucumber::Messages::Pickle, the parsed pickle.
      attr_reader :pickle

      # The test case associated to the Pickle
      attr_reader :test_case
    end
  end
end
