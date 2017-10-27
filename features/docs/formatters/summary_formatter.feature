Feature: Spec formatter

  This formatter mimics the output from tools like RSpec or Mocha, giving an 
  overview of each feature and scenario but omitting the steps.

  Background:
    Given the standard step definitions

  @todo-windows
  Scenario: A couple of scenarios
    Given a file named "features/test.feature" with:
    """
    Feature: Test
      Scenario: Passing
        Given this step passes

      Scenario: Failing
        Given this step fails
    """
    When I run `cucumber --format summary`
    Then it should fail with exactly:
    """
    Test
      Passing ✓
      Failing ✗

    Failing Scenarios:
    cucumber features/test.feature:5 # Scenario: Failing

    2 scenarios (1 failed, 1 passed)
    2 steps (1 failed, 1 passed)
    0m0.012s

    """

