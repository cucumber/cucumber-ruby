# frozen_string_literal: true

module Cucumber
  # In memory repository i.e. a thread based link to cucumber-query
  class Repository
    attr_accessor :meta, :test_run_started, :test_run_finished
    attr_reader :attachments_by_test_case_started_id, :attachments_by_test_run_hook_started_id,
                :hook_by_id,
                :pickle_by_id, :pickle_step_by_id,
                :step_by_id, :step_definition_by_id,
                :test_case_by_id, :test_case_started_by_id, :test_case_finished_by_test_case_started_id,
                :test_run_hook_started_by_id, :test_run_hook_finished_by_test_run_hook_started_id,
                :test_step_by_id, :test_steps_started_by_test_case_started_id, :test_steps_finished_by_test_case_started_id

    # TODO: Missing structs (3)
    #   final Map<Object, Lineage> lineageById = new HashMap<>();
    #   final Map<String, List<Suggestion>> suggestionsByPickleStepId = new LinkedHashMap<>();
    #   final List<UndefinedParameterType> undefinedParameterTypes = new ArrayList<>();

    def initialize
      @attachments_by_test_case_started_id = Hash.new { |hash, key| hash[key] = [] }
      @attachments_by_test_run_hook_started_id = Hash.new { |hash, key| hash[key] = [] }
      @hook_by_id = {}
      @pickle_by_id = {}
      @pickle_step_by_id = {}
      @step_by_id = {}
      @step_definition_by_id = {}
      @test_case_by_id = {}
      @test_case_started_by_id = {}
      @test_case_finished_by_test_case_started_id = {}
      @test_run_hook_started_by_id = {}
      @test_run_hook_finished_by_test_run_hook_started_id = {}
      @test_step_by_id = {}
      @test_steps_started_by_test_case_started_id = Hash.new { |hash, key| hash[key] = [] }
      @test_steps_finished_by_test_case_started_id = Hash.new { |hash, key| hash[key] = [] }
    end

    def update(envelope)
      return self.meta = envelope.meta if envelope.meta
      return self.test_run_started = envelope.test_run_started if envelope.test_run_started
      return self.test_run_finished = envelope.test_run_finished if envelope.test_run_finished
      return update_attachment(envelope.attachment) if envelope.attachment
      return update_gherkin_document(envelope.gherkin_document) if envelope.gherkin_document
      return update_hook(envelope.hook) if envelope.hook
      return update_pickle(envelope.pickle) if envelope.pickle
      return update_step_definition(envelope.step_definition) if envelope.step_definition
      return update_test_run_hook_started(envelope.test_run_hook_started) if envelope.test_run_hook_started
      return update_test_run_hook_finished(envelope.test_run_hook_finished) if envelope.test_run_hook_finished
      return update_test_case_started(envelope.test_case_started) if envelope.test_case_started
      return update_test_case_finished(envelope.test_case_finished) if envelope.test_case_finished
      return update_test_step_started(envelope.test_step_started) if envelope.test_step_started
      return update_test_step_finished(envelope.test_step_finished) if envelope.test_step_finished
      return update_test_case(envelope.test_case) if envelope.test_case

      nil
    end

    private

    def update_attachment(attachment)
      # TODO: Update both attachment structs at a later date.
      # Java impl
      #             attachment.getTestCaseStartedId()
      #                 .ifPresent(testCaseStartedId -> this.attachmentsByTestCaseStartedId.compute(testCaseStartedId, updateList(attachment)));
      #         attachment.getTestRunHookStartedId()
      #                 .ifPresent(testRunHookStartedId -> this.attachmentsByTestRunHookStartedId.compute(testRunHookStartedId, updateList(attachment)));

      test_case_started_id = attachment&.test_case_started_id
      test_run_hook_started_id = attachment&.test_run_hook_started_id # TODO: This does not seem to be a property on attachment?

      attachments_by_test_case_started_id if test_case_started_id
      attachments_by_test_run_hook_started_id if test_run_hook_started_id
    end

    def update_feature(feature)
      feature.children.each do |feature_child|
        update_steps(feature_child.background.steps) if feature_child.background
        update_scenario(feature_child.scenario) if feature_child.scenario
        next unless feature_child.rule

        feature_child.rule.children.each do |rule_child|
          update_steps(rule_child.background.steps) if rule_child.background
          update_scenario(rule_child.scenario) if rule_child.scenario
        end
      end
    end

    def update_gherkin_document(gherkin_document)
      # TODO: Update lineage at a later date. Java Impl -> lineageById.putAll(Lineages.of(document));
      update_feature(gherkin_document.feature) if gherkin_document.feature
    end

    def update_hook(hook)
      hook_by_id[hook.id] = hook
    end

    def update_pickle(pickle)
      pickle_by_id[pickle.id] = pickle
      pickle.steps.each { |pickle_step| pickle_step_by_id[pickle_step.id] = pickle_step }
    end

    def update_scenario(scenario)
      update_steps(scenario.steps)
    end

    def update_steps(steps)
      steps.each { |step| step_by_id[step.id] = step }
    end

    def update_step_definition(step_definition)
      step_definition_by_id[step_definition.id] = step_definition
    end

    def update_test_case(test_case)
      test_case_by_id[test_case.id] = test_case
      test_case.test_steps.each { |test_step| test_step_by_id[test_step.id] = test_step }
    end

    def update_test_case_started(test_case_started)
      test_case_started_by_id[test_case_started.id] = test_case_started
    end

    def update_test_case_finished(test_case_finished)
      test_case_finished_by_test_case_started_id[test_case_finished.test_case_started_id] = test_case_finished
    end

    def update_test_run_hook_started(test_run_hook_started)
      test_run_hook_started_by_id[test_run_hook_started.id] = test_run_hook_started
    end

    def update_test_run_hook_finished(test_run_hook_finished)
      test_run_hook_finished_by_test_run_hook_started_id[test_run_hook_finished.test_run_hook_started_id] = test_run_hook_finished
    end

    def update_test_step_started(test_step_started)
      test_steps_started_by_test_case_started_id[test_step_started.test_case_started_id] << test_step_started
    end

    def update_test_step_finished(test_step_finished)
      test_steps_finished_by_test_case_started_id[test_step_finished.test_case_started_id] << test_step_finished
    end
  end
end
