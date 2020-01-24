# frozen_string_literal: true

require 'cucumber/formatter/io'
require 'cucumber/formatter/query/hook_by_test_step'
require 'cucumber/formatter/query/pickle_by_test'
require 'cucumber/formatter/query/pickle_step_by_test_step'
require 'cucumber/formatter/query/step_definitions_by_test_step'


module Cucumber
  module Formatter
    # The formatter used for <tt>--format message</tt>
    class Message
      include Io

      def initialize(config)
        @config = config
        @hook_by_test_step = Query::HookByTestStep.new(config)
        @pickle_by_test = Query::PickleByTest.new(config)
        @pickle_step_by_test_step = Query::PickleStepByTestStep.new(config)
        @step_definitions_by_test_step = Query::StepDefinitionsByTestStep.new(config)

        @io = ensure_io(config.out_stream)
        config.on_event :envelope, &method(:on_envelope)
        config.on_event :test_case_ready, &method(:on_test_case_ready)

      end

      def output_envelope(envelope)
        envelope.write_ndjson_to(@io)
      end

      def on_envelope(event)
        output_envelope(event.envelope)
      end

      def on_test_case_ready(event)
        message = Cucumber::Messages::Envelope.new(
          test_case: Cucumber::Messages::TestCase.new(
            id: event.test_case.id,
            pickle_id: @pickle_by_test.pickle_id(event.test_case),
            test_steps: event.test_case.test_steps.map do |step|
              if step.hook?
                Cucumber::Messages::TestCase::TestStep.new(
                  id: step.id,
                  pickle_step_id: @hook_by_test_step.hook_id(step)
                )
              else
                Cucumber::Messages::TestCase::TestStep.new(
                  id: step.id,
                  pickle_step_id: @pickle_step_by_test_step.pickle_step_id(step),
                  step_definition_ids: @step_definitions_by_test_step.step_definition_ids(step)
                )
              end
            end
          )
        )

        output_envelope(message)
      end

    end
  end
end
