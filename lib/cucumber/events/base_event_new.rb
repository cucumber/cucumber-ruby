# frozen_string_literal: true

module Cucumber
  module Events
    class BaseEventNew
      # @return [Symbol] the underscored name of the class to be used as the key in an event registry
      def self.event_id
        raise 'Must be implemented in subclass'
      end

      def to_h
        instance_variables.to_h { |variable_name| [variable_name[1..].to_sym, instance_variable_get(variable_name)] }
      end

      def to_hash
        to_h
      end

      def event_id
        self.class.event_id
      end
    end
  end
end
