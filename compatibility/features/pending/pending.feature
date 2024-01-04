Feature: Pending steps
  During development, step definitions can signal at runtime that they are
  not yet implemented (or "pending") by returning or throwing a particular
  value.

  This causes subsequent steps in the scenario to be skipped, and the overall
  result to be treated as a failure.

  Scenario: Unimplemented step signals pending status
    Given an unimplemented pending step

  Scenario: Steps before unimplemented steps are executed
    Given an implemented non-pending step
    And an unimplemented pending step

  Scenario: Steps after unimplemented steps are skipped
    Given an unimplemented pending step
    And an implemented step that is skipped
