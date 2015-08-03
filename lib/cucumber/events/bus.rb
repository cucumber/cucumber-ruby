module Cucumber
  module Events
    class Bus
      def initialize
        @handlers = {}
      end

      def on_event(event_id, handler_object = nil, &handler_proc)
        handler = handler_proc || handler_object
        raise ArgumentError.new("Please pass either an object or a handler block") unless handler
        event_class = parse_event_id(event_id)
        handlers_for(event_class) << handler
      end

      def notify(event)
        handlers_for(event.class).each { |handler| handler.call(event) }
      end

      private

      def handlers_for(event_class)
        @handlers[event_class.to_s] ||= []
      end

      def parse_event_id(event_id)
        case event_id
        when Class
          return event_id
        when String
          return Object.const_get(event_id)
        else
          Object.const_get("Cucumber::Events::#{camel_case(event_id)}")
        end
      end

      def camel_case(underscored_name)
        underscored_name.to_s.split("_").map { |word| word.upcase[0] + word[1..-1] }.join
      end

    end
  end
end
