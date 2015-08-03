module Cucumber
  module Events
    class Bus
      def initialize
        @handlers = Hash.new(UnknownEventHandler)
      end

      def on_event(event_type, &handler)
        @handlers[event_type] = handler
      end

      def notify(event)
        @handlers[event.class].call(event)
      end

      UnknownEventHandler = ->(event) {}
    end
  end
end
