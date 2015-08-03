module Cucumber
  module Events
    class Bus
      def initialize
        @handlers = {}
      end

      def on_event(event_class, &handler)
        handlers_for(event_class) << handler
      end

      def notify(event)
        handlers_for(event.class).each { |handler| handler.call(event) }
      end

      private

      def handlers_for(event_class)
        @handlers[event_class] ||= []
      end

    end
  end
end
