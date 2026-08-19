# frozen_string_literal: true

require 'cucumber/core/event/base'

Dir[File.join(__dir__, 'events', '*.rb')].each do |file|
  require_relative File.join('events', File.basename(file))
end

module Cucumber
  # Events tell you what's happening while Cucumber runs your features.
  #
  # They're designed to be read-only, appropriate for writing formatters and other
  # output tools. If you need to be able to influence the result of a scenario, use a {RbSupport::RbDsl hook} instead.
  #
  # To subscribe to an event, use {Cucumber::Configuration#on_event}
  #
  # @example
  #   InstallPlugin do |config|
  #     config.on_event :test_case_finished do |event|
  #       puts event.result
  #     end
  #   end
  #
  module Events
    def self.make_event_bus
      Core::EventBus.new(registry)
    end

    def self.registry
      Core::EventBus.build_registry(
        AttachCalled,
        GherkinSourceParsed,
        GherkinSourceRead,
        HookTestStepCreated,
        StepActivated,
        StepDefinitionRegistered,
        TestCaseCreated,
        TestCaseFinished,
        TestCaseStarted,
        TestCaseReady,
        TestRunFinished,
        TestRunHookFinished,
        TestRunHookStarted,
        TestRunStarted,
        TestStepCreated,
        TestStepFinished,
        TestStepStarted,
        Envelope,
        UndefinedParameterType
      )
    end
  end
end
