# frozen_string_literal: true

module Cucumber
  module Events
    # An archetype of what each Cucumber Event defined in cucumber-ruby must adhere to
    class Base
      # The "key" name of the class to be used as the key in the event registry (Underscored name symbolized)
      #   @return [Symbol]
      def self.event_id
        raise 'Must be implemented in subclass'
      end

      # The properties of each event. Stored in iVar named format - where the key is the name of the iVar
      #   @return [Hash<Symbol>]
      def to_h
        instance_variables.to_h { |variable_name| [variable_name[1..].to_sym, instance_variable_get(variable_name)] }
      end

      def event_id
        self.class.event_id
      end
    end
  end
end
