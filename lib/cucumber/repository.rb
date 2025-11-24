module Cucumber
  # In memory repository i.e. a thread based link to cucumber-query
  class Repository
    attr_accessor :meta,
                  :test_run_started,
                  :test_run_finished

    def update(envelope)
      return this.meta = envelope.meta if envelope.meta
      return this.test_run_started = envelope.test_run_started if envelope.test_run_started
      return this.test_run_finished = envelope.test_run_finished if envelope.test_run_finished

      # TODO: We need to improve this
      return update_pickle(envelope.pickle) if envelope.pickle


      # Change all of the below lines to look like the above lines
      # NB: One of these items will be fixed up later
      #
      # return @test_run_hook_started = envelope.test_run_hook_started if envelope.test_run_hook_started
      # return @test_run_hook_finished = envelope.test_run_hook_finished if envelope.test_run_hook_finished
      # return @test_case_started = envelope.test_case_started if envelope.test_case_started
      # return @test_case_finished = envelope.test_case_finished if envelope.test_case_finished
      # return @test_step_started = envelope.test_step_started if envelope.test_step_started
      # return @test_step_finished = envelope.test_step_finished if envelope.test_step_finished
      # return @test_case = envelope.test_case if envelope.test_case
    end

    def pickle_by_id
      @pickle_by_id ||= {}
    end

    def pickle_step_by_id
      @pickle_step_by_id ||= {}
    end

    private

    def update_pickle(pickle)
      # This method also needs to update the hash `pickle_step_by_id`
      @pickle_by_id[pickle.id] = pickle
    end
  end
end


## Placeholder code that "might" be useful
#    def update_gherkin_document(gherkin_document)
#       :not_yet_implemented
#     end
#
#     def update_pickle(pickle)
#       :not_yet_implemented
#     end
#
#     def update_test_case(test_case)
#       @test_case_by_id[test_case.id] = test_case
#
#       # NOT YET IMPLEMENTED THE BELOW - NEXT STEPS from javascript implementation
#       # this.testCaseByPickleId.set(testCase.pickleId, testCase)
#       # testCase.testSteps.forEach((testStep) => {
#       #   this.testStepById.set(testStep.id, testStep)
#       #                            this.pickleIdByTestStepId.set(testStep.id, testCase.pickleId)
#       # this.pickleStepIdByTestStepId.set(testStep.id, testStep.pickleStepId)
#       # this.testStepIdsByPickleStepId.put(testStep.pickleStepId, testStep.id)
#       # this.stepMatchArgumentsListsByPickleStepId.set(
#       #   testStep.pickleStepId,
#       #   testStep.stepMatchArgumentsLists
#       # )
#       # })
#     end
#
#     def update_test_case_started(test_case_started)
#       @test_case_started_by_id[test_case_started.id] = test_case_started
#
#       # NOT YET IMPLEMENTED THE BELOW - NEXT STEPS from javascript implementation
#       #     /*
#       #     when a test case attempt starts besides the first one, clear all existing results
#       #     and attachments for that test case, so we always report on the latest attempt
#       #     (applies to legacy pickle-oriented query methods only)
#       #      */
#       #     const testCase = this.testCaseById.get(testCaseStarted.testCaseId)
#       #     if (testCase) {
#       #       this.testStepResultByPickleId.delete(testCase.pickleId)
#       #       for (const testStep of testCase.testSteps) {
#       #         this.testStepResultsByPickleStepId.delete(testStep.pickleStepId)
#       #         this.testStepResultsbyTestStepId.delete(testStep.id)
#       #         this.attachmentsByTestStepId.delete(testStep.id)
#       #       }
#       #     }
#     end
#
#     def update_test_step_started(test_step_started)
#       :not_yet_implemented
#     end
#
#     def update_attachment(attachment)
#       :not_yet_implemented
#     end
#
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
#     def update_test_case_finished(test_case_finished)
#       :not_yet_implemented
#     end