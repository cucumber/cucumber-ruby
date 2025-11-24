module Cucumber
  # In memory repository i.e. a thread based link to cucumber-query
  class Repository
    attr_accessor :meta,
                  :test_run_started,
                  :test_run_finished

    def update(envelope)
      return @meta = envelope.meta if envelope.meta
      return @test_run_started = envelope.test_run_started if envelope.test_run_started
      return @test_run_finished = envelope.test_run_finished if envelope.test_run_finished

      # TODO: We will need to improve these over time
      return update_pickle(envelope.pickle) if envelope.pickle
      return update_test_case(envelope.test_case) if envelope.test_case

      # TODO: These items are completed AS IS
      return update_test_case_started(envelope.test_case) if envelope.test_case
      return update_test_run_hook_started(envelope.test_case) if envelope.test_run_hook_started
      return update_test_run_hook_finished(envelope.test_case) if envelope.test_run_hook_finished

      # Change all the below lines to look like the above lines
      # return @test_case_finished = envelope.test_case_finished if envelope.test_case_finished
      # return @test_step_started = envelope.test_step_started if envelope.test_step_started
      # return @test_step_finished = envelope.test_step_finished if envelope.test_step_finished

      nil
    end

    def pickle_by_id
      @pickle_by_id ||= {}
    end

    # TODO: Not used yet
    def pickle_step_by_id
      @pickle_step_by_id ||= {}
    end

    def test_case_by_id
      @test_case_by_id ||= {}
    end

    def test_run_hook_started_by_id
      @test_run_hook_started_by_id ||= {}
    end

    def test_run_hook_finished_by_test_run_hook_started_id
      @test_run_hook_finished_by_test_run_hook_started_id ||= {}
    end

    # TODO: Not used yet
    def test_step_by_id
      @test_step_by_id ||= {}
    end

    def test_case_started_by_id
      @test_case_started_by_id ||= {}
    end

    private

    def update_pickle(pickle)
      # This method also needs to update the hash `pickle_step_by_id`
      pickle_by_id[pickle.id] = pickle
    end

    def update_test_case(test_case)
      # This method also needs to update the hash `test_step_by_id`
      test_case_by_id[test_case.id] = test_case
    end

    def update_test_case_started(test_case_started)
      test_case_started_by_id[test_case_started.id] = test_case_started
    end

    def update_test_run_hook_started(test_run_hook_started)
      test_run_hook_started_by_id[test_run_hook_started.id] = test_run_hook_started
    end

    def update_test_run_hook_finished(test_run_hook_finished)
      test_run_hook_finished_by_test_run_hook_started_id[test_run_hook_finished.test_run_hook_started_id] = test_run_hook_finished
    end
  end
end

## Placeholder code that "might" be useful
#     def update_test_step_finished(test_step_finished)
#       @test_step_finished_by_test_case_started_id[test_step_finished.test_case_started_id] = test_step_finished
#
#       # NOT YET IMPLEMENTED THE BELOW - NEXT STEPS from javascript implementation
#       #     const pickleId = this.pickleIdByTestStepId.get(testStepFinished.testStepId)
#       #     this.testStepResultByPickleId.put(pickleId, testStepFinished.testStepResult)
#       #     const testStep = this.testStepById.get(testStepFinished.testStepId)
#       #     this.testStepResultsByPickleStepId.put(testStep.pickleStepId, testStepFinished.testStepResult)
#       #     this.testStepResultsbyTestStepId.put(testStep.id, testStepFinished.testStepResult)
#       #   }
#     end
#