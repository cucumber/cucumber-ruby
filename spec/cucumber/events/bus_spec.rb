require "cucumber/events/bus"

module Cucumber
  module Events
    describe Bus do
      it "calls named handler with event payload" do
        bus = Bus.new
        payload = double(:an_event)

        received_payload = nil
        bus.on_event(:abcd1234) do |event|
          received_payload = event
        end

        bus.notify(:abcd1234, payload)

        expect(received_payload).to eq(payload)
      end

      it "does not call for different event" do
        bus = Bus.new

        handler_called = false
        bus.on_event(:abcd1234) do |event|
          handler_called = true
        end

        bus.notify(:xyz987, double(:payload))

        expect(handler_called).to eq(false)
      end
    end
  end
end
