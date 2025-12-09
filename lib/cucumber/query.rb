# frozen_string_literal: true

require 'cucumber/repository'

# Given one Cucumber Message, find another.
#
# Queries can be made while the test run is incomplete - and this will naturally return incomplete results
# see <a href="https://github.com/cucumber/messages?tab=readme-ov-file#message-overview">Cucumber Messages - Message Overview</a>
#
module Cucumber
  class Query
    attr_reader :repository
    private :repository

    def initialize(repository)
      @repository = repository
    end

    # TODO: count methods (1/2) Complete
    #   Missing: countMostSevereTestStepResultStatus

    # TODO: findAll methods (11/12) Complete
    #   Missing: findAllUndefinedParameterTypes

    # TODO: find****By methods (10/25) Complete
    #   Complete: findMeta (1 variant)
    #   Missing: findLocationOf (1 variant) - This strictly speaking isn't a findBy but is located within them
    #   Missing: findSuggestionsBy (2 variants)
    #   Missing: findUnambiguousStepDefinitionBy (1 variant)
    #   Missing: findTestRunDuration (1 variant) - This strictly speaking isn't a findBy but is located within them
    #   Missing: findTestRunFinished (1 variant) - This strictly speaking isn't a findBy but is located within them
    #   Missing: findTestRunStarted (1 variant) - This strictly speaking isn't a findBy but is located within them
    #   Missing: findTestStepFinishedAndTestStepBy (1 variant)
    #   Missing: findMostSevereTestStepResultBy (2 variants)
    #   Missing: findAttachmentsBy (2 variants)
    #   Missing: findTestCaseDurationBy (2 variant)
    #   Missing: findLineageBy (9 variants!)
    #   Fully Complete (5/5): findPickleBy (5 variants)
    #   Requires Refactor (3/3): findHookBy (3 variants)
    #   Requires Refactor (2/2): findTestStepsFinishedBy (2 variants)
    #   Complete: findTestRunHookStartedBy (1 variant)
    #   Complete: findTestRunHookFinishedBy (1 variant)
    #   Complete: findPickleStepBy (1 variant)
    #   Complete: findStepDefinitionsBy (1 variant)
    #   Complete: findStepBy (1 variant)
    #   Fully Complete (2/2): findTestStepsStartedBy (2 variants)
    #   Fully Complete (2/2): findTestStepBy (2 variants)
    #   Fully Complete (3/3): findTestCaseStartedBy (3 variants)
    #   Fully Complete (1/1): findTestCaseFinishedBy (1 variant)
    #   Fully Complete (4/4): findTestCaseBy (4 variants)

    def count_test_cases_started
      find_all_test_case_started.length
    end

    def find_all_pickles
      repository.pickle_by_id.values
    end

    def find_all_pickle_steps
      repository.pickle_step_by_id.values
    end

    def find_all_step_definitions
      repository.step_definition_by_id.values
    end

    # This finds all test cases from the following conditions (UNION)
    #   -> Test cases that have started, but not yet finished
    #   -> Test cases that have started, finished, but that will NOT be retried
    def find_all_test_case_started
      repository.test_case_started_by_id.values.select do |test_case_started|
        test_case_finished = find_test_case_finished_by(test_case_started)
        test_case_finished.nil? || !test_case_finished.will_be_retried
      end
    end

    # This finds all test cases that have finished AND will not be retried
    def find_all_test_case_finished
      repository.test_case_finished_by_test_case_started_id.values.reject(&:will_be_retried)
    end

    def find_all_test_cases
      repository.test_case_by_id.values
    end

    def find_all_test_run_hook_started
      repository.test_run_hook_started_by_id.values
    end

    def find_all_test_run_hook_finished
      repository.test_run_hook_finished_by_test_run_hook_started_id.values
    end

    def find_all_test_step_started
      repository.test_steps_started_by_test_case_started_id.values.flatten
    end

    def find_all_test_step_finished
      repository.test_steps_finished_by_test_case_started_id.values.flatten
    end

    def find_all_test_steps
      repository.test_step_by_id.values
    end

    # This method will be called with 1 of these 3 messages
    #   [TestStep || TestRunHookStarted || TestRunHookFinished]
    def find_hook_by(message)
      ensure_only_message_types!(message, %i[test_step test_run_hook_started test_run_hook_finished], '#find_hook_by')

      # TODO: Refactor this to be nicer use the below as example
      # test_case_started = message.respond_to?(:test_case_started_id) ? find_test_case_started_by(message) : message
      case message
      when Cucumber::Messages::TestRunHookFinished
        message_or_nil = find_test_run_hook_started_by(message)
        message_or_nil ? find_hook_by(message_or_nil) : nil
      else
        repository.hook_by_id[message.hook_id]
      end
    end

    def find_meta
      repository.meta
    end

    # This method will be called with 1 of these 5 messages
    #   [TestCase || TestCaseStarted || TestCaseFinished || TestStepStarted || TestStepFinished]
    def find_pickle_by(message)
      ensure_only_message_types!(message, %i[test_case test_case_started test_case_finished test_step_started test_step_finished], '#find_pickle_by')

      test_case = message.is_a?(Cucumber::Messages::TestCase) ? message : find_test_case_by(message)
      repository.pickle_by_id[test_case.pickle_id]
    end

    # This method will be called with only 1 message
    #   [TestStep]
    def find_pickle_step_by(test_step)
      ensure_only_message_types!(message, %i[test_step], '#find_pickle_step_by')

      repository.pickle_step_by_id[test_step.pickle_step_id]
    end

    # This method will be called with only 1 message
    #   [PickleStep]
    def find_step_by(pickle_step)
      ensure_only_message_types!(message, %i[pickle_step], '#find_step_by')

      repository.step_by_id[pickle_step.ast_node_ids.first]
    end

    # This method will be called with only 1 message
    #   [TestStep]
    def find_step_definitions_by(test_step)
      ensure_only_message_types!(message, %i[test_step], '#find_step_definitions_by')

      ids = test_step.step_definition_ids.nil? ? [] : test_step.step_definition_ids
      ids.map { |id| repository.step_definition_by_id[id] }.compact
    end

    # This method will be called with 1 of these 4 messages
    #   [TestCaseStarted || TestCaseFinished || TestStepStarted || TestStepFinished]
    def find_test_case_by(message)
      ensure_only_message_types!(message, %i[test_case_started test_case_finished test_step_started test_step_finished], '#find_test_case_by')

      # TODO: Refactor this to use object checking
      test_case_started = message.respond_to?(:test_case_started_id) ? find_test_case_started_by(message) : message
      repository.test_case_by_id[test_case_started.test_case_id]
    end

    # This method will be called with 1 of these 3 messages
    #   [TestCaseFinished || TestStepStarted || TestStepFinished]
    def find_test_case_started_by(message)
      ensure_only_message_types!(message, %i[test_case_finished test_step_started test_step_finished], '#find_test_case_started_by')

      repository.test_case_started_by_id[message.test_case_started_id]
    end

    # This method will be called with only 1 message
    #   [TestCaseStarted]
    def find_test_case_finished_by(test_case_started)
      ensure_only_message_types!(message, %i[test_case_started], '#find_test_case_finished_by')

      repository.test_case_finished_by_test_case_started_id[test_case_started.id]
    end

    # This method will be called with only 1 message
    #   [TestRunHookFinished]
    def find_test_run_hook_started_by(test_run_hook_finished)
      ensure_only_message_types!(message, %i[test_run_hook_finished], '#find_test_run_hook_started_by')

      repository.test_run_hook_started_by_id[test_run_hook_finished.test_run_hook_started_id]
    end

    # This method will be called with only 1 message
    #   [TestRunHookStarted]
    def find_test_run_hook_finished_by(test_run_hook_started)
      ensure_only_message_types!(message, %i[test_run_hook_started], '#find_test_run_hook_finished_by')

      repository.test_run_hook_finished_by_test_run_hook_started_id[test_run_hook_started.id]
    end

    # This method will be called with 1 of these 2 messages
    #   [TestStepStarted || TestStepFinished]
    def find_test_step_by(message)
      ensure_only_message_types!(message, %i[test_case_started test_case_finished], '#find_test_step_by')

      repository.test_step_by_id[message.test_step_id]
    end

    # This method will be called with 1 of these 2 messages
    #   [TestCaseStarted || TestCaseFinished]
    def find_test_steps_started_by(message)
      ensure_only_message_types!(message, %i[test_case_started test_case_finished], '#find_test_steps_started_by')

      key = message.is_a?(Cucumber::Messages::TestCaseStarted) ? message.id : message.test_case_started_id
      # For Concurrency purposes
      Array.new(repository.test_steps_started_by_test_case_started_id.fetch(key, []))
    end

    # This method will be called with 1 of these 2 messages
    #   [TestCaseStarted || TestCaseFinished]
    def find_test_steps_finished_by(message)
      ensure_only_message_types!(message, %i[test_case_started test_case_finished], '#find_test_steps_finished_by')

      if message.is_a?(Cucumber::Messages::TestCaseStarted)
        test_steps_finished = test_steps_finished_by_test_case_started_id.fetch(message.id, [])
        # For Concurrency purposes
        Array.new(test_steps_finished)
      else
        tc_started_message = find_test_case_started_by(message)
        tc_started_message.nil? ? [] : find_test_steps_finished_by(tc_started_message)
      end
    end
  end

  private

  def ensure_only_message_types!(supplied_message, permissible_message_types, method_name)
    raise ArgumentError, "Supplied argument is not a Cucumber Message. Argument: #{supplied_message.class}" unless supplied_message.is_a?(Cucumber::Messages::Message)

    permitted_klasses = permissible_message_types.map { |message| message_types[message] }
    raise ArgumentError, "Supplied message type '#{supplied_message.class}' is not permitted to be used when calling #{method_name}" unless permitted_klasses.include?(supplied_message.class)
  end

  def message_types
    {
      pickle_step: Cucumber::Messages::PickleStep,
      test_case: Cucumber::Messages::TestCase,
      test_case_started: Cucumber::Messages::TestCaseStarted,
      test_case_finished: Cucumber::Messages::TestCaseFinished,
      test_run_hook_started: Cucumber::Messages::TestRunHookStarted,
      test_run_hook_finished: Cucumber::Messages::TestRunHookFinished,
      test_step: Cucumber::Messages::TestStep,
      test_step_started: Cucumber::Messages::TestStepStarted,
      test_step_finished: Cucumber::Messages::TestStepFinished
    }
  end
end
