Feature: Retry
  Some Cucumber implementations support a Retry mechanism, where test cases that fail
  can be retried up to a limited number of attempts in the same test run.

  Non-passing statuses other than FAILED won't trigger a retry, as they are not
  going to pass however many times we attempt them.

  Scenario: Test cases that pass aren't retried
    Given a step that always passes

  Scenario: Test cases that fail are retried if within the --retry limit
    Given a step that passes the second time

  Scenario: Test cases that fail will continue to retry up to the --retry limit
    Given a step that passes the third time

  Scenario: Test cases won't retry after failing more than the --retry limit
    Given a step that always fails

  Scenario: Test cases won't retry when the status is UNDEFINED
    Given a non-existent step
