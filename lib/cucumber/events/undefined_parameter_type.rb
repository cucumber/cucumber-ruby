# frozen_string_literal: true

module Cucumber
  module Events
    class UndefinedParameterType < Base
      attr_reader :type_name, :expression

      def self.event_id
        :undefined_parameter_type
      end

      def initialize(type_name, expression)
        @type_name = type_name
        @expression = expression
        super()
      end
    end
  end
end
