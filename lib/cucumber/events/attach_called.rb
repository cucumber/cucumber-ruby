# frozen_string_literal: true

require 'cucumber/core/events'

module Cucumber
  module Events
    # Fired when attach is called in a step definition
    class AttachCalled < Core::Event.new(:src, :media_type, :filename)
      # The attachment body
      attr_reader :src

      # The content media type
      attr_reader :media_type

      # An optional filename
      attr_reader :filename
    end
  end
end
