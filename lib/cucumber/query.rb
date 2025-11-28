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
    #   Missing: findAttachmentsBy (2 variants)
    #   Requires Review (3/3): findHookBy (3 variants)
    #   Missing: findMeta (1 variant) - This strictly speaking isn't a findBy but is located within them
    #   Missing: findMostSevereTestStepResultBy (2 variants)
    #   Missing: findLocationOf (1 variant) - This strictly speaking isn't a findBy but is located within them
    #   Partially Complete (3/5): findPickleBy (5 variants)
    #   Complete: findPickleStepBy (1 variant)
    #   Missing: findSuggestionsBy (2 variants)
    #   Complete: findStepBy (1 variant)
    #   Complete: findStepDefinitionsBy (1 variant)
    #   Missing: findUnambiguousStepDefinitionBy (1 variant)
    #   Fully Complete (4/4): findTestCaseBy (4 variants)
    #   Missing: findTestCaseDurationBy (2 variant)
    #   Fully Complete (3/3): findTestCaseStartedBy (3 variants)
    #   Fully Complete (1/1): findTestCaseFinishedBy (1 variant)
    #   Complete: findTestRunHookStartedBy (1 variant)
    #   Complete: findTestRunHookFinishedBy (1 variant)
    #   Missing: findTestRunDuration (1 variant) - This strictly speaking isn't a findBy but is located within them
    #   Missing: findTestRunFinished (1 variant) - This strictly speaking isn't a findBy but is located within them
    #   Missing: findTestRunStarted (1 variant) - This strictly speaking isn't a findBy but is located within them
    #   Fully Complete (2/2): findTestStepBy (2 variants)
    #   Fully Complete (2/2): findTestStepsStartedBy (2 variants)
    #   Requires Review (2/2): findTestStepsFinishedBy (2 variants)
    #   Missing: findTestStepFinishedAndTestStepBy (1 variant)
    #   Missing: findLineageBy (9 variants!)

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
      repository.test_case_finished_by_test_case_started_id.values.reject do |test_case_finished|
        test_case_finished.will_be_retried
      end
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
    def find_hook_by(element)
      # TODO: Check with Java here, the first and second implementations look identical but are coded diff in Java
      if element.is_a?(Cucumber::Messages::TestStep)
        repository.hook_by_id[element.hook_id]
      elsif element.is_a?(Cucumber::Messages::TestRunHookStarted)
        repository.hook_by_id[element.hook_id]
      elsif element.is_a?(Cucumber::Messages::TestRunHookFinished)
        # TODO: Not sure how this one is intended to work? As it returns a single hook yet we're enumerating it?
        find_test_run_hook_started_by(element).flat_map { |test_run_hook_started| find_hook_by(test_run_hook_started) }
      else
        raise 'Must provide either a TestStep, TestRunHookStarted or TestRunHookFinished message to use #find_hook_by'
      end
    end

    # This method will be called with 1 of these 3 messages
    #   [TestCaseStarted || TestCaseFinished || TestStepStarted]
    def find_pickle_by(element)
      test_case = find_test_case_by(element)
      raise 'Expected to find TestCase from TestCaseStarted' unless test_case

      repository.pickle_by_id[test_case.pickle_id]
    end

    # This method will be called with only 1 message
    #   [TestStep]
    def find_pickle_step_by(test_step)
      raise 'Must provide a TestStep message to use #find_pickle_step_by' unless test_step.is_a?(Cucumber::Messages::TestStep)

      repository.pickle_step_by_id[test_step.pickle_step_id]
    end

    # This method will be called with only 1 message
    #   [PickleStep]
    def find_step_by(pickle_step)
      raise 'Must provide a PickleStep message to use #find_step_by' unless test_step.is_a?(Cucumber::Messages::PickleStep)

      repository.step_by_id[pickle_step.ast_node_ids.first]
    end

    # This method will be called with only 1 message
    #   [TestStep]
    def find_step_definitions_by(test_step)
      raise 'Must provide a TestStep message to use #find_step_definitions_by' unless test_step.is_a?(Cucumber::Messages::TestStep)

      # TODO: QQ) Shouldn't the default value of `step_definition_ids` be [] instead of nil
      ids = test_step.step_definition_ids.nil? ? [] : test_step.step_definition_ids
      ids.map { |id| repository.step_definition_by_id[id] }.compact
    end

    # This method will be called with 1 of these 4 messages
    #   [TestCaseStarted || TestCaseFinished || TestStepStarted || TestStepFinished]
    def find_test_case_by(element)
      test_case_started = element.respond_to?(:test_case_started_id) ? find_test_case_started_by(element) : element
      raise 'Expected to find TestCaseStarted by TestStepStarted' unless test_case_started

      repository.test_case_by_id[test_case_started.test_case_id]
    end

    # This method will be called with 1 of these 3 messages
    #   [TestCaseFinished || TestStepStarted || TestStepFinished]
    def find_test_case_started_by(element)
      repository.test_case_started_by_id[element.test_case_started_id]
    end

    # This method will be called with only 1 message
    #   [TestCaseStarted]
    def find_test_case_finished_by(test_case_started)
      repository.test_case_finished_by_test_case_started_id[test_case_started.id]
    end

    # This method will be called with only 1 message
    #   [TestRunHookFinished]
    def find_test_run_hook_started_by(test_run_hook_finished)
      unless test_run_hook_finished.is_a?(Cucumber::Messages::TestRunHookFinished)
        raise 'Must provide a TestRunHookFinished message to use #find_test_run_hook_started_by'
      end

      repository.test_run_hook_started_by_id[test_run_hook_finished.test_run_hook_started_id]
    end

    # This method will be called with only 1 message
    #   [TestRunHookFinished]
    def find_test_run_hook_finished_by(test_run_hook_started)
      unless test_run_hook_started.is_a?(Cucumber::Messages::TestRunHookStarted)
        raise 'Must provide a TestRunHookStarted message to use #find_test_run_hook_finished_by'
      end

      repository.test_run_hook_finished_by_test_run_hook_started_id[test_run_hook_started.id]
    end

    # This method will be called with 1 of these 2 messages
    #   [TestStepStarted || TestStepFinished]
    def find_test_step_by(element)
      unless [Cucumber::Messages::TestStepStarted, Cucumber::Messages::TestStepFinished].include?(element)
        raise 'Must provide either a TestStepStarted or TestStepFinished message to use #find_test_step_by'
      end

      repository.test_step_by_id[element.test_step_id]
    end

    # This method will be called with 1 of these 2 messages
    #   [TestCaseStarted || TestCaseFinished]
    def find_test_steps_started_by(element)
      key =
        if element.is_a?(Cucumber::Messages::TestCaseStarted)
          test_case_started.id
        elsif element.is_a?(Cucumber::Messages::TestCaseFinished)
          test_case_finished.test_case_started_id
        else
          raise 'Must provide either a TestCaseStarted or TestCaseFinished message to use #find_test_steps_started_by'
        end

      # For Concurrency purposes
      Array.new(repository.test_steps_started_by_test_case_started_id.fetch(key, []))
    end

    # This method will be called with 1 of these 2 messages
    #   [TestCaseStarted || TestCaseFinished]
    def find_test_steps_finished_by(element)
      if element.is_a?(Cucumber::Messages::TestCaseStarted)
        test_steps_finished = test_steps_finished_by_test_case_started_id.fetch(element.id, [])
        # For Concurrency purposes
        Array.new(test_steps_finished)
      elsif element.is_a?(Cucumber::Messages::TestCaseFinished)
        # TODO: The logic in Java says orElseGet a blank array. But here we're recursively calling this method with either
        # a tc_started_message or `nil` so would we want it to error the 2nd time round or return `[]`
        tc_started_message = find_test_case_started_by(element)
        find_test_steps_finished_by(tc_started_message)
      else
        raise 'Must provide either a TestCaseStarted or TestCaseFinished message to use #find_test_steps_finished_by'
      end
    end
  end
end
