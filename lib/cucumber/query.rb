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

    # TODO: find****By methods (3/25) Complete
    #   Missing: findAttachmentsBy (2 variants)
    #   Missing: findHookBy (3 variants)
    #   Missing: findMeta (1 variant) - This strictly speaking isn't a findBy but is located within them
    #   Missing: findMostSevereTestStepResultBy (2 variants)
    #   Missing: findLocationOf (1 variant) - This strictly speaking isn't a findBy but is located within them
    #   Partially Complete (3/5): findPickleBy (5 variants)
    #   Missing: findPickleStepBy (1 variant)
    #   Missing: findSuggestionsBy (2 variants)
    #   Missing: findStepBy (1 variant)
    #   Missing: findStepDefinitionsBy (1 variant)
    #   Missing: findUnambiguousStepDefinitionBy (1 variant)
    #   Fully Complete (4/4): findTestCaseBy (4 variants)
    #   Missing: findTestCaseDurationBy (2 variant)
    #   Fully Complete (3/3): findTestCaseStartedBy (3 variants)
    #   Fully Complete (1/1): findTestCaseFinishedBy (1 variant)
    #   Missing: findTestRunHookFinishedBy (1 variant)
    #   Missing: findTestRunHookStartedBy (1 variant)
    #   Missing: findTestRunDuration (1 variant) - This strictly speaking isn't a findBy but is located within them
    #   Missing: findTestRunFinished (1 variant) - This strictly speaking isn't a findBy but is located within them
    #   Missing: findTestRunStarted (1 variant) - This strictly speaking isn't a findBy but is located within them
    #   Missing: findTestStepBy (2 variants)
    #   Missing: findTestStepsStartedBy (2 variants)
    #   Missing: findTestStepsFinishedBy (2 variants)
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

    # This finds all test cases that have started, but not yet finished
    # AS WELL AS (AND)
    # This finds all test cases that have started AND have finished, but that will NOT be retried
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
    #   [TestCaseStarted || TestCaseFinished || TestStepStarted]
    def find_pickle_by(element)
      test_case = find_test_case_by(element)
      raise 'Expected to find TestCase from TestCaseStarted' unless test_case

      repository.pickle_by_id[test_case.pickle_id]
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
  end
end
