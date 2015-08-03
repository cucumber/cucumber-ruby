require "cucumber/events/bus"

module Cucumber
  module Events
    describe Bus do
      class TestEvent
      end

      class AnotherTestEvent
      end

      let(:bus) { Bus.new }

      it "calls named handler with event payload" do
        event = TestEvent.new

        received_payload = nil
        bus.on_event(TestEvent) do |event|
          received_payload = event
        end

        bus.notify event

        expect(received_payload).to eq(event)
      end

      it "does not call for different event" do
        event = AnotherTestEvent.new

        handler_called = false
        bus.on_event(TestEvent) do |event|
          handler_called = true
        end

        bus.notify event

        expect(handler_called).to eq(false)
      end

      it "broadcasts to multiple subscribers" do
        received_events = []

        bus.on_event(TestEvent) do |event|
          received_events << event
        end
        bus.on_event(TestEvent) do |event|
          received_events << event
        end

        bus.notify TestEvent.new

        expect(received_events.length).to eq 2
      end
    end
  end
end
