Feature: predicatble ids
  The --predicatble-ids flag generates sequential IDs.

  Background:
    Given a file named "features/simple.feature" with:
      """
      Feature: Good
        Scenario: Passing
          Given this step passes
      """
    And a file named "features/step_definitions/support_code.rb" with:
      """
      Before { }
      Given(/^Whatever step$/) { }
      """

  Scenario: by default, IDs are UUIDs
    When I run `cucumber --format message`
    Then all IDs in the message output should be UUIDs

  Scenario: when the option --predictable-ids is set, IDs are sequential
    When I run `cucumber --format message --predictable-ids`
    Then all IDs in the message output should be incremental