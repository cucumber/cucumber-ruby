@wire
Feature: Wire Protocol
  In order to be allow Cucumber to touch my app in intimate places
  As a developer on platform which doesn't support Ruby
  I want a low-level protocol which Cucumber can use to run steps within my app

  Background:
    Given a standard Cucumber project directory structure
    And a file named "features/wired.feature" with:
      """
      Feature: Over the wire

        Scenario: Wired
          Given we're all wired
          And we like it

      """
    And a file named "features/step_definitions/some_remote_place.wire" with:
      """
      host: localhost
      port: 98989

      """

  Scenario: Dry run finds one step
    Given there is a wire server running on port 98989 which understands the following protocol:
      | request                                     | response                    |
      | {"step_matches":{"step_name":"we're all wired","formatted_step_name":null}} | {"step_match":[{"id":"1"}]} |
      | {"step_matches":{"step_name":"we like it","formatted_step_name":null}}      | {"step_match":[]}           |
    When I run cucumber --dry-run -q features/wired.feature
    Then STDERR should be empty
    And it should pass with
      """
      Feature: Over the wire

        Scenario: Wired
          Given we're all wired
          And we like it

      1 scenario (1 skipped)
      2 steps (1 skipped, 1 undefined)

      """

  # Scenario: Invoke a Step Definition which fails
  #   And it should fail with
  #     """
  #     Feature: Over the wire
  #
  #       Scenario: Wired
  #         Given we're all wired
  #           the wires are down (Cucumber::WireSupport::WireException)
  #           remote/stepdefs.rb:2:in `parse!'
  #           features/wired.feature:4:in `Given we're all wired'
  #
  #     Failing Scenarios:
  #     cucumber features/wired.feature:3 # Scenario: Wired
  #
  #     1 scenario (1 failed)
  #     1 step (1 failed)
  #
  #     """
  #
  # Scenario: Invoke a Step Definition with a table that fails on diff!
  #   And it should fail with
  #     """
  #     Feature: Over the wire
  #
  #       Scenario: Wired
  #         Given we're all wired on:
  #           | drug |
  #           | love |
  #           | life |
  #           Tables were not identical (Cucumber::Ast::Table::Different)
  #           remote/stepdefs.rb:2:in `parse!'
  #           features/wired_table.feature:4:in `Given we're all wired on:'
  #
  #     Failing Scenarios:
  #     cucumber features/wired_table.feature:3 # Scenario: Wired
  #
  #     1 scenario (1 failed)
  #     1 step (1 failed)
  #
  #     """