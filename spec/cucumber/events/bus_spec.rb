require "cucumber/events/bus"

module Cucumber
  module Events
    describe Bus do
      class TestEvent
      end

      class AnotherTestEvent
      end

      let(:bus) { Bus.new }
      let(:test_event) { TestEvent.new }
      let(:another_test_event) { AnotherTestEvent.new }

      it "calls subscriber with event payload" do
        received_payload = nil
        bus.on_event(TestEvent) do |event|
          received_payload = event
        end

        bus.notify test_event

        expect(received_payload).to eq(test_event)
      end

      it "does not call subscribers for other events" do
        handler_called = false
        bus.on_event(TestEvent) do |event|
          handler_called = true
        end

        bus.notify another_test_event

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

        bus.notify test_event

        expect(received_events.length).to eq 2
        expect(received_events).to all eq test_event
      end

      it "allows subscription by string" do
        received_payload = nil
        bus.on_event('Cucumber::Events::TestEvent') do |event|
          received_payload = event
        end

        bus.notify test_event

        expect(received_payload).to eq(test_event)
      end

      it "allows handlers that are objects with a `call` method" do
        class MyHandler
          attr_reader :received_payload

          def call(event)
            @received_payload = event
          end
        end

        handler = MyHandler.new
        bus.on_event(TestEvent, handler)

        bus.notify test_event

        expect(handler.received_payload).to eq test_event
      end
    end
  end
end
