# frozen_string_literal: true

require 'cucumber/core/events'

module Cucumber
  module Events
    class UndefinedParameterType < Core::Event.new(:type_name, :expression)
      attr_reader :type_name, :expression
    end
  end
end
