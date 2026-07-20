# frozen_string_literal: true

require 'base64'
require 'json'

require 'cucumber/formatter/backtrace_filter'
require 'cucumber/query'

require_relative 'message_handlers'

module Cucumber
  module Formatter
    class MessageBuilder
      include Cucumber::Messages::Helpers::TimeConversion
      include Io
      include MessageHandlers
      include Console

      def initialize(config)
        @config = config
        @ast_lookup = AstLookup.new(config)
        @repository = Cucumber::Repository.new

        @test_run_started_id = config.test_run_started_id

        # Fake Query objects
        @test_case_by_step_id = {}
        @pickle_id_by_test_case_id = {}
        @pickle_id_step_by_test_step_id = {}
        @hook_id_by_test_step_id = {}
        @step_definition_ids_by_test_step_id = {}
        @step_match_arguments_by_test_step_id = {}

        # Ensure all handlers for events occur after all ivars are instantiated

        config.on_event :gherkin_source_parsed, &method(:on_gherkin_source_parsed)

        config.on_event :hook_test_step_created, &method(:on_hook_test_step_created)

        config.on_event :step_activated, &method(:on_step_activated)

        config.on_event :test_case_created, &method(:on_test_case_created)
        config.on_event :test_case_ready, &method(:on_test_case_ready)

        config.on_event :test_run_started, &method(:on_test_run_started)
        config.on_event :test_run_finished, &method(:on_test_run_finished)

        config.on_event :test_step_created, &method(:on_test_step_created)
        config.on_event :test_step_finished, &method(:on_test_step_finished)

        config.on_event :attach_called, &method(:on_attach_called)
        config.on_event :envelope, &method(:on_envelope)
      end

      def on_envelope(event)
        store_current_test_run_hook_started_id(event)
        @current_test_step_id = event.envelope.test_step_started.test_step_id if event.envelope.test_step_started
        return unless event.envelope.test_case_started

        @current_test_case_started_id = event.envelope.test_case_started.id
        @current_test_run_hook_started_id = nil
        @repository.update(event.envelope)
      end

      def on_attach_called(event)
        attachment_data =
          if @current_test_run_hook_started_id.nil?
            {
              test_step_id: @current_test_step_id,
              test_case_started_id: @current_test_case_started_id,
              media_type: event.media_type,
              file_name: event.filename,
              timestamp: time_to_timestamp(Time.now)
            }
          else
            {
              test_run_hook_started_id: @current_test_run_hook_started_id,
              media_type: event.media_type,
              file_name: event.filename,
              timestamp: time_to_timestamp(Time.now)
            }
          end

        streamed_file = event.src.encoding == Encoding::BINARY

        if streamed_file
          attachment_data[:content_encoding] = Cucumber::Messages::AttachmentContentEncoding::BASE64
          attachment_data[:body] = Base64.strict_encode64(event.src)
        else
          attachment_data[:content_encoding] = Cucumber::Messages::AttachmentContentEncoding::IDENTITY
          attachment_data[:body] = event.src.is_a?(Hash) ? event.src.to_json : event.src
        end

        message = Cucumber::Messages::Envelope.new(attachment: Cucumber::Messages::Attachment.new(**attachment_data))
        @config.event_bus.envelope(message)
      end

      private

      def on_gherkin_source_parsed(_event)
        # TODO: Handle GherkinSourceParsed
      end

      def on_hook_test_step_created(event)
        @hook_id_by_test_step_id[event.test_step.id] = event.hook.id
      end

      def on_step_activated(event)
        @step_definition_ids_by_test_step_id[event.test_step.id] << event.step_match.step_definition.id
        @step_match_arguments_by_test_step_id[event.test_step.id] = event.step_match.step_arguments
      end

      def on_test_case_created(event)
        @pickle_id_by_test_case_id[event.test_case.id] = event.pickle.id
      end

      def on_test_case_ready(event)
        message = Cucumber::Messages::Envelope.new(
          test_case: Cucumber::Messages::TestCase.new(
            id: event.test_case.id,
            pickle_id: fake_query_pickle_id(event.test_case),
            test_steps: event.test_case.test_steps.map { |step| test_step_to_message(step) },
            test_run_started_id: @test_run_started_id
          )
        )

        # TODO: This may be a redundant update. But for now we're leaving this in whilst we're in the transitory phase
        @repository.update(message)

        @config.event_bus.envelope(message)
      end

      def on_test_run_started(*)
        message = Cucumber::Messages::Envelope.new(
          test_run_started: Cucumber::Messages::TestRunStarted.new(
            timestamp: time_to_timestamp(Time.now),
            id: @test_run_started_id
          )
        )

        @config.event_bus.envelope(message)
      end

      def on_test_run_finished(event)
        message = Cucumber::Messages::Envelope.new(
          test_run_finished: Cucumber::Messages::TestRunFinished.new(
            timestamp: time_to_timestamp(Time.now),
            success: event.success,
            test_run_started_id: @test_run_started_id
          )
        )

        @config.event_bus.envelope(message)
      end

      def on_test_step_created(event)
        @pickle_id_step_by_test_step_id[event.test_step.id] = event.pickle_step.id
        @step_definition_ids_by_test_step_id[event.test_step.id] = []
      end

      def on_test_step_finished(event)
        output_snippet_envelope(event)
      end

      def output_snippet_envelope(event)
        return unless event.result.undefined?

        collect_snippet_data(event.test_step, @ast_lookup)
        snippet_text_proc = lambda do |step_keyword, step_name, multiline_arg|
          snippet_text(step_keyword, step_name, multiline_arg)
        end

        message = generate_snippet_envelope(snippet_text_proc, event)
        @config.event_bus.envelope(message)
        # To ensure we don't redistribute the "same" snippets over and over again
        snippets_input.clear
      end

      def generate_snippet_envelope(snippet_text_proc, event)
        snippets_array = snippets_input.map do |data|
          snippet_text_proc.call(data.actual_keyword, data.step.text, data.step.multiline_arg)
        end.uniq

        Cucumber::Messages::Envelope.new(
          suggestion: Cucumber::Messages::Suggestion.new(
            id: @config.id_generator.new_id,
            pickle_step_id: @repository.test_step_by_id[event.test_step.id].pickle_step_id,
            snippets: snippets_array.map { |code_snippet| Cucumber::Messages::Snippet.new(language: 'ruby', code: code_snippet) }
          )
        )
      end

      def on_undefined_parameter_type(event)
        message = Cucumber::Messages::Envelope.new(
          undefined_parameter_type: Cucumber::Messages::UndefinedParameterType.new(
            name: event.type_name,
            expression: event.expression
          )
        )

        @config.event_bus.envelope(message)
      end

      def test_step_to_message(step)
        return hook_step_to_message(step) if step.hook?

        Cucumber::Messages::TestStep.new(
          id: step.id,
          pickle_step_id: @pickle_id_step_by_test_step_id[step.id],
          step_definition_ids: fake_query_step_definition_ids(step),
          step_match_arguments_lists: step_match_arguments_lists(step)
        )
      end

      def hook_step_to_message(step)
        Cucumber::Messages::TestStep.new(
          id: step.id,
          hook_id: @hook_id_by_test_step_id[step.id]
        )
      end

      def step_match_arguments_lists(step)
        match_arguments = step_match_arguments(step)
        if match_arguments.nil?
          []
        else
          [Cucumber::Messages::StepMatchArgumentsList.new(step_match_arguments: match_arguments)]
        end
      end

      def step_match_arguments(step)
        fake_query_step_match_arguments(step)&.map do |argument|
          Cucumber::Messages::StepMatchArgument.new(
            group: argument_group_to_message(argument.group),
            parameter_type_name: parameter_type_name(argument)
          )
        end
      end

      def argument_group_to_message(group)
        Cucumber::Messages::Group.new(
          start: group.start,
          value: group.value,
          children: group.children&.map { |child| argument_group_to_message(child) }
        )
      end

      def parameter_type_name(step_match_argument)
        step_match_argument.parameter_type&.name if step_match_argument.respond_to?(:parameter_type)
      end

      def create_error_message(message_element)
        <<~ERROR_MESSAGE
          #{message_element.message} (#{message_element.class})
          #{message_element.backtrace}
        ERROR_MESSAGE
      end

      def create_exception_object(result, message_element)
        return unless result.failed?

        Cucumber::Messages::Exception.new(
          type: message_element.class,
          message: message_element.message,
          stack_trace: message_element.backtrace.join("\n")
        )
      end

      def fake_query_hook_id(test_step)
        @hook_id_by_test_step_id.fetch(test_step.id)
      end

      def fake_query_pickle_id(test_case)
        @pickle_id_by_test_case_id.fetch(test_case.id)
      end

      def fake_query_step_definition_ids(test_step)
        @step_definition_ids_by_test_step_id.fetch(test_step.id)
      end

      def fake_query_step_match_arguments(test_step)
        @step_match_arguments_by_test_step_id.fetch(test_step.id, nil)
      end
    end
  end
end
