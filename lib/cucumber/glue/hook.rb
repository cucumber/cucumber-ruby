# frozen_string_literal: true

require 'cucumber/glue/invoke_in_world'

module Cucumber
  module Glue
    # TODO: Kill pointless wrapper for Before, After and AfterStep hooks with fire
    class Hook
      attr_reader :id, :tag_expressions, :location, :name

      def initialize(id, registry, tag_expressions, proc, name: nil)
        @id = id
        @registry = registry
        @name = name
        @tag_expressions = tag_expressions
        @proc = proc
        @location = Cucumber::Core::Test::Location.from_source_location(*@proc.source_location)
      end

      def invoke(pseudo_method, arguments, &block)
        check_arity = false
        InvokeInWorld.cucumber_instance_exec_in(
          @registry.current_world,
          check_arity,
          pseudo_method,
          *[arguments, block].flatten.compact,
          &@proc
        )
      end

      def to_envelope(type)
        Cucumber::Messages::Envelope.new(
          hook: Cucumber::Messages::Hook.new(
            id: id,
            name: name,
            tag_expression: tag_expressions.empty? ? nil : tag_expressions.join(' '),
            type: hook_type_to_enum_value[type.to_sym],
            source_reference: Cucumber::Messages::SourceReference.new(
              uri: location.file,
              location: Cucumber::Messages::Location.new(
                line: location.lines.first
              )
            )
          )
        )
      end

      private

      def hook_type_to_enum_value
        {
          before: 'BEFORE_TEST_CASE',
          after: 'AFTER_TEST_CASE',
          around: nil, # This needs deleting and removing from cucumber-ruby in v11
          after_step: 'AFTER_TEST_STEP',
          install_plugin: 'BEFORE_TEST_RUN',
          before_all: 'BEFORE_TEST_RUN',
          after_all: 'AFTER_TEST_RUN'
        }
      end
    end
  end
end
