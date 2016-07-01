@wip
Feature: Stream a single passing step

  Emits a stream of events compatible with https://github.com/cucumber/cucumber-pretty-formatter
  
  The events should come out in the following order:
  
  ```
  TestRunStarted
    GherkinSourceRead
    StepDefinitionFound
    TestCaseStarted
      TestStepStarted
      TestStepFinished
    TestCaseFinished
  TestRunFinished
  ```

  Background:
    Given the standard step definitions
    And a file named "features/simple.feature" with:
      """
      Feature:
        Scenario:
          Given this step passes
      """
    When I run the feature with the event stream output

  Scenario: Start test run
    Then test run should have started
    
  Scenario: Gherkin source is read after the test starts
    When the test run has started
    Then the gherkin source should have been read
    
  Scenario: Look for a step definition
    When the gherkin source has been read
    Then the step defininion for "a passing step" should have been found

  Scenario: Start the test case
    When the step definition has been found
    Then the test case should have started

  Scenario: Start the test step
    When the test case has started
    Then the test step for "this step passes" should have started
    
  Scenario: Finish the test step
    When the test step "this step passes" has started
    Then the test step should have finished

  Scenario: Finish the test case
    When the test step "this step passes" has finished
    Then the test case should have finished

  Scenario: Finish the test run
    When the test case has finished
    Then the test run should have finished
