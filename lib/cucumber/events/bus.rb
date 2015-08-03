module Cucumber
  module Events
    class Bus
      def initialize
        @handlers = {}
      end

      def on_event(event_class, handler_object = nil, &handler_proc)
        handler = handler_proc || handler_object
        raise ArgumentError.new("Please pass either an object or a handler block") unless handler
        handlers_for(event_class) << handler
      end

      def notify(event)
        handlers_for(event.class).each { |handler| handler.call(event) }
      end

      private

      def handlers_for(event_class)
        @handlers[event_class.to_s] ||= []
      end

    end
  end
end
