Feature: Event Stream Formatter

  Emits a stream of events compatible with https://github.com/cucumber/cucumber-pretty-formatter

  Background:
    Given the standard step definitions

  Scenario: A simple scenario
    Given a file named "features/simple.feature" with:
      """
      Feature:
        Scenario:
          Given this step passes
      """
    When I run `cucumber -q --format Cucumber::Formatter::EventStream`
    Then it should pass
    And the stdout should contain exactly:
      """
      {"event":"TestRunStarted","protocol_version":"0.0.1"}
      {"event":"GherkinSourceRead","id":"features/simple.feature:1","source":"Feature:\n  Scenario:\n    Given this step passes"}
      {"event":"StepDefinitionFound","source_id":"features/simple.feature:3","definition_id": "features/step_definitions/steps.rb:1"}
      {"event":"TestCaseStarted","id":"features/simple.feature:2"}
      {"event":"TestStepStarted","id":"features/simple.feature:3"}
      {"event":"TestStepPassed","id":"features/simple.feature:3"}
      {"event":"TestCasePassed","id":"features/simple.feature:2"}
      {"event":"TestRunFinished"}
      """

  Scenario: An outline
    Given a file named "features/outline.feature" with:
      """
      Feature:
        Scenario Outline:
          Given this step <status>
          Examples:
            | status |
            | passes |
      """
    When I run `cucumber -q --format Cucumber::Formatter::EventStream`
    Then it should pass
    And the stdout should contain exactly:
      """
      {"event":"TestRunStarted","protocol_version":"0.0.1"}
      {"event":"GherkinSourceRead","id":"features/outline.feature:1","source":"Feature:\n  Scenario Outline:\n    Given this step <status>\n    Examples:\n      | status |\n      | passes |"}
      {"event":"StepDefinitionFound","source_id":"features/simple.feature:6","definition_id": "features/step_definitions/steps.rb:1"}
      {"event":"TestCaseStarted","id":"features/outline.feature:6"}
      {"event":"TestStepStarted","id":"features/outline.feature:6"}
      {"event":"TestStepPassed","id":"features/outline.feature:6"}
      {"event":"TestCasePassed","id":"features/outline.feature:6"}
      {"event":"TestRunFinished"}
      """

  Scenario: A simple scenario with a before hook
