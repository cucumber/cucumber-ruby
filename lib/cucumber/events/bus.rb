module Cucumber
  module Events
    class Bus
      def initialize
        @handlers = Hash.new(UnknownEventHandler)
      end

      def on_event(event_name, &handler)
        @handlers[event_name] = handler
      end

      def notify(event_name, payload)
        @handlers[event_name].call(payload)
      end

      UnknownEventHandler = ->(event) {}
    end
  end
end
