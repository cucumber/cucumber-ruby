module Cucumber
  class Query
    def initialize
      @attachments_by_test_case_started_id = [[]]
      @attachments_by_test_step_id = []
      @hooks_by_id = {}
      @lineage_by_id = []
      @meta = :not_sure_on_this
      @pickle_by_id = []
      @pickle_id_by_test_step_id = []
      @pickle_step_by_id = []
      @pickle_step_id_by_test_step_id = []
      @step_by_id = []
      @step_definition_by_id = {}
      @step_match_arguments_lists_by_pickle_step_id = [{}]
      @test_case_by_id = []
      @test_case_by_pickle_id = []
      @test_case_finished_by_test_case_started_id = [[]]
      @test_case_started_by_id = {}
      @test_run_started = :not_sure_on_this
      @test_run_finished = :not_sure_on_this
      @test_step_finished_by_test_case_started_id = {}
      @test_step_ids_by_pickle_step_id = [{}]
      @test_step_result_by_pickle_id = [{}]
      @test_step_results_by_pickle_step_id = [[]]
      @test_step_results_by_test_step_id = [[]]
      @test_step_started_by_test_case_started_id = [[]]
    end

    # FIRST TWO THINGS TO FIX
    # Use query to establish
    # 1) `on_test_step_started` - Establish what the TestStepStarted message property is for `test_case_started_id` is
    # 2) `on_test_step_finished` - Establish what the TestStepFinished message property is for `test_case_started_id` is
    def update(envelope)
      @meta = envelope.meta if envelope.meta
      update_gherkin_document(envelope.gherkin_document) if envelope.gherkin_document
      update_pickle(envelope.pickle) if envelope.gherkin_document
      @hooks_by_id[envelope.hook.id] = envelope.hook if envelope.hook
      @step_definition_by_id[envelope.step_definition.id] = envelope.step_definition if envelope.step_definition
      @test_run_started = envelope.test_run_started if envelope.test_run_started
      update_test_case(envelope.test_case) if envelope.test_case
      update_test_case_started(envelope.test_case_started) if envelope.test_case_started
      update_test_step_started(envelope.test_step_started) if envelope.test_step_started
      update_attachment(envelope.attachment) if envelope.attachment
      update_test_step_finished(envelope.test_step_finished) if envelope.test_step_finished
      update_test_case_finished(envelope.test_case_finished) if envelope.test_case_finished
      @test_run_finished = envelope.test_run_finished if envelope.test_run_finished
    end

    private

    def update_gherkin_document(gherkin_document)
      :not_yet_implemented
    end

    def update_pickle(pickle)
      :not_yet_implemented
    end

    def update_test_case(test_case)
      :not_yet_implemented
    end

    def update_test_case_started(test_case_started)
      @test_case_started_by_id[test_case_started.id] = test_case_started

      # NOT YET IMPLEMENTED THE BELOW - NEXT STEPS from javascript implementation
      #     /*
      #     when a test case attempt starts besides the first one, clear all existing results
      #     and attachments for that test case, so we always report on the latest attempt
      #     (applies to legacy pickle-oriented query methods only)
      #      */
      #     const testCase = this.testCaseById.get(testCaseStarted.testCaseId)
      #     if (testCase) {
      #       this.testStepResultByPickleId.delete(testCase.pickleId)
      #       for (const testStep of testCase.testSteps) {
      #         this.testStepResultsByPickleStepId.delete(testStep.pickleStepId)
      #         this.testStepResultsbyTestStepId.delete(testStep.id)
      #         this.attachmentsByTestStepId.delete(testStep.id)
      #       }
      #     }
    end

    def update_test_step_started(test_step_started)
      :not_yet_implemented
    end

    def update_attachment(attachment)
      :not_yet_implemented
    end

    def update_test_step_finished(test_step_finished)
      @test_step_finished_by_test_case_started_id[test_step_finished.test_case_started_id] = test_step_finished

      # NOT YET IMPLEMENTED THE BELOW - NEXT STEPS from javascript implementation
      #     const pickleId = this.pickleIdByTestStepId.get(testStepFinished.testStepId)
      #     this.testStepResultByPickleId.put(pickleId, testStepFinished.testStepResult)
      #     const testStep = this.testStepById.get(testStepFinished.testStepId)
      #     this.testStepResultsByPickleStepId.put(testStep.pickleStepId, testStepFinished.testStepResult)
      #     this.testStepResultsbyTestStepId.put(testStep.id, testStepFinished.testStepResult)
      #   }
    end

    def update_test_case_finished(test_case_finished)
      :not_yet_implemented
    end
  end
end
