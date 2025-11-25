# frozen_string_literal: true

module Cucumber
  # In memory repository i.e. a thread based link to cucumber-query
  class Repository
    attr_accessor :meta, :test_run_started, :test_run_finished

    def update(envelope)
      return self.meta = envelope.meta if envelope.meta
      return self.test_run_started = envelope.test_run_started if envelope.test_run_started
      return self.test_run_finished = envelope.test_run_finished if envelope.test_run_finished

      # TODO: These items are completed AS IS. Should be good to sign off
      return update_test_run_hook_started(envelope.test_run_hook_started) if envelope.test_run_hook_started
      return update_test_run_hook_finished(envelope.test_run_hook_finished) if envelope.test_run_hook_finished
      return update_test_case_started(envelope.test_case_started) if envelope.test_case_started
      return update_test_case_finished(envelope.test_case_finished) if envelope.test_case_finished
      return update_test_step_started(envelope.test_step_started) if envelope.test_step_started
      return update_test_step_finished(envelope.test_step_finished) if envelope.test_step_finished
      return update_pickle(envelope.pickle) if envelope.pickle
      return update_test_case(envelope.test_case) if envelope.test_case

      nil
    end

    def pickle_by_id
      @pickle_by_id ||= {}
    end

    def pickle_step_by_id
      @pickle_step_by_id ||= {}
    end

    def test_case_by_id
      @test_case_by_id ||= {}
    end

    def test_case_finished_by_test_case_started_id
      @test_case_finished_by_test_case_started_id ||= {}
    end

    def test_case_started_by_id
      @test_case_started_by_id ||= {}
    end

    def test_run_hook_started_by_id
      @test_run_hook_started_by_id ||= {}
    end

    def test_run_hook_finished_by_test_run_hook_started_id
      @test_run_hook_finished_by_test_run_hook_started_id ||= {}
    end

    def test_step_by_id
      @test_step_by_id ||= {}
    end

    def test_steps_finished_by_test_case_started_id
      @test_steps_finished_by_test_case_started_id ||= Hash.new { |hash, key| hash[key] = [] }
    end

    def test_steps_started_by_test_case_started_id
      @test_steps_started_by_test_case_started_id ||= Hash.new { |hash, key| hash[key] = [] }
    end

    private

    def update_pickle(pickle)
      pickle_by_id[pickle.id] = pickle
      pickle.steps.each { |pickle_step| pickle_step_by_id[pickle_step.id] = pickle_step }
    end

    def update_test_case(test_case)
      test_case_by_id[test_case.id] = test_case
      test_case.test_steps.each { |test_step| test_step_by_id[test_step.id] = test_step }
    end

    def update_test_case_finished(test_case_finished)
      test_case_finished_by_test_case_started_id[test_case_finished.test_case_started_id] = test_case_finished
    end

    def update_test_case_started(test_case_started)
      test_case_started_by_id[test_case_started.id] = test_case_started
    end

    def update_test_run_hook_finished(test_run_hook_finished)
      test_run_hook_finished_by_test_run_hook_started_id[test_run_hook_finished.test_run_hook_started_id] = test_run_hook_finished
    end

    def update_test_run_hook_started(test_run_hook_started)
      test_run_hook_started_by_id[test_run_hook_started.id] = test_run_hook_started
    end

    def update_test_step_finished(test_step_finished)
      test_steps_finished_by_test_case_started_id[test_step_finished.test_case_started_id] << test_step_finished
    end

    def update_test_step_started(test_step_started)
      test_steps_started_by_test_case_started_id[test_step_started.test_case_started_id] << test_step_started
    end
  end
end
