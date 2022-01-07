Feature: Message output formatter

  This formatter emits a stream of Newline-Delimited JSON (NDJSON) documents
  as events occur during the test run.

  You can read more about the message protocol [here](https://github.com/cucumber/common/tree/main/messages).

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
      meta
      source
      gherkinDocument
      pickle
      pickle
      testCase
      testCase
      testRunStarted
      testCaseStarted
      testStepStarted
      testStepFinished
      testCaseFinished
      testCaseStarted
      testStepStarted
      testStepFinished
      testCaseFinished
      testRunFinished
      """

  Scenario: it sets "testRunFinished"."success" to false if something failed
    Given a file named "features/steps.rb" with:
      """
      Given('a passed step') {}
      Given('a failed step') { fail }
      """
    When I run `cucumber features/my_feature.feature --format message`
    Then output should be valid NDJSON
    And the output should contain:
    """
    {"testRunFinished":{"success":false
    """

  Scenario: it sets "testRunFinished"."success" to true if nothing failed
    Given a file named "features/steps.rb" with:
      """
      Given('a passed step') {}
      Given('a failed step') { skip_this_scenario }
      """
    When I run `cucumber features/my_feature.feature --format message`
    Then output should be valid NDJSON
    And the output should contain:
    """
    {"testRunFinished":{"success":true
    """