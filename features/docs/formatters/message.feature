Feature: Protobuf message output formatter

  Background:
    Given a file named "features/my_feature.feature" with:
      """
      Feature: Some feature

        Scenario Outline: a scenario
          Given a <status> step

        Examples:
          | status |
          | passed |
          | failed |
      """

  Scenario: it produces NDJSON messages
    When I run `cucumber features/my_feature.feature --format message`
    Then output should be valid NDJSON
    And messages types should be:
      """
      gherkinDocument
      pickle
      pickle
      testCase
      testCase
      testCaseStarted
      testStepFinished
      testCaseFinished
      testCaseStarted
      testStepFinished
      testCaseFinished
      """

