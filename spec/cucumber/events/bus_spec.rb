require "cucumber/events/bus"

module Cucumber
  module Events
    describe Bus do
      class TestEvent
      end

      class AnotherTestEvent
      end

      it "calls named handler with event payload" do
        bus = Bus.new
        event = TestEvent.new

        received_payload = nil
        bus.on_event(TestEvent) do |event|
          received_payload = event
        end

        bus.notify event

        expect(received_payload).to eq(event)
      end

      it "does not call for different event" do
        bus = Bus.new
        event = AnotherTestEvent.new

        handler_called = false
        bus.on_event(TestEvent) do |event|
          handler_called = true
        end

        bus.notify event

        expect(handler_called).to eq(false)
      end
    end
  end
end
