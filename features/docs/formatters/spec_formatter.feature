Feature: Spec formatter

  This formatter mimic the output from tools like RSpec or Mocha, giving an 
  overview of each feature and scenario, omitting the steps.

  Background:
    Given the standard step definitions

  Scenario: A couple of scenarios
    Given a file named "features/test.feature" with:
    """
    Feature: Test
      Scenario: Passing
        Given this step passes

      Scenario: Failing
        Given this step fails
    """
    When I run `cucumber --format spec`
    Then it should fail with exactly:
    """
    Test
      Passing ✓
      Failing ✗

    2 scenarios (1 passed, 1 failed)
    2 steps (1 passed, 1 failed)
    """

