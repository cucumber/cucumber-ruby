module Cucumber
  class Query
    attr_reader :repository
    private :repository

    def initialize(repository)
      @repository = repository
    end

    def find_all_pickles
      repository.values
    end

    # This method will be called with 1 of these 3 messages
    # TestCaseStarted | TestCaseFinished | TestStepStarted
    def find_pickle_by(element)
      test_case = find_test_case_by(element)
      raise 'Expected to find TestCase from TestCaseStarted' unless test_case

      repository.pickle_by_id[test_case.pickle_id]
    end

    # This method will be called with 1 of these 4 messages
    # TestCaseStarted | TestCaseFinished | TestStepStarted | TestStepFinished
    def find_test_case_by(element)
      test_case_started = element.respond_to?(:test_case_started_id) ? find_test_case_started_by(element) : element
      raise 'Expected to find TestCaseStarted by TestStepStarted' unless test_case_started

      repository.test_case_by_id[test_case_started.test_case_id]
    end

    # This method will be called with 1 of these 3 messages
    # TestCaseFinished | TestStepStarted | TestStepFinished
    def find_test_case_started_by(element)
      repository.test_case_started_by_id[element.test_case_started_id]
    end
  end
end
