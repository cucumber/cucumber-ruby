Feature: Skipping scenarios

  Hooks and step definitions are able to signal at runtime that the scenario should
  be skipped by raising a particular kind of exception status (For example PENDING or SKIPPED).

  This can be useful in certain situations e.g. the current environment doesn't have
  the right conditions for running a particular scenario.

  @skip
  Scenario: Skipping from a Before hook
    Given a step that is skipped

  Scenario: Skipping from a step doesn't affect the previous steps
    Given a step that does not skip
    And I skip a step

  Scenario: Skipping from a step causes the rest of the scenario to be skipped
    Given I skip a step
    And a step that is skipped
