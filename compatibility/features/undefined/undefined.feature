Feature: Undefined steps

  At runtime, Cucumber may encounter a step in a scenario that it cannot match to a
  step definition. In these cases, the scenario is not able to run and so the step status
  will be UNDEFINED, with subsequent steps being SKIPPED and the overall result will be FAILURE

  Scenario: An undefined step causes a failure
    Given a step that is yet to be defined

  Scenario: Steps before undefined steps are executed
    Given an implemented step
    And a step that is yet to be defined

  Scenario: Steps after undefined steps are skipped
    Given a step that is yet to be defined
    And a step that will be skipped
