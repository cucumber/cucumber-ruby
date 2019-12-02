require 'cucumber/core/events'

module Cucumber
  module Events
    # A Cucumber::Messages envelope
    class Envelope < Core::Event.new(:envelope)
      attr_reader :envelope
    end
  end
end
