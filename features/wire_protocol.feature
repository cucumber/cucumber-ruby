@wire
Feature: Wire Protocol
  In order to be allow Cucumber to touch my app in intimate places
  As a developer on platform which doesn't support Ruby
  I want a low-level protocol which Cucumber can use to run steps within my app

  Background:
    Given a standard Cucumber project directory structure
    And a file named "features/wired.feature" with:
      """
        Scenario: Wired
          Given we're all wired

      """
    And a file named "features/step_definitions/some_remote_place.wire" with:
      """
      host: localhost
      port: 98989

      """


  #
  # step_matches
  #
  # When the features have been parsed, Cucumber will send a step_matches message to ask the wire end
  # if it can match a step name. This happens for each of the steps in each of the features.
  # The wire end replies with a step_match array, containing the IDs of any step definitions that could
  # be invoked for the given step name.

  Scenario: Dry run finds no step match
    Given there is a wire server running on port 98989 which understands the following protocol:
      | request                                          | response          |
      | {"step_matches":{"step_name":"we're all wired"}} | {"step_match":[]} |
    When I run cucumber --dry-run -f progress features
    And it should pass with
      """
      U

      1 scenario (1 undefined)
      1 step (1 undefined)

      """

  Scenario: Dry run finds a step match
    Given there is a wire server running on port 98989 which understands the following protocol:
      | request                                          | response                               |
      | {"step_matches":{"step_name":"we're all wired"}} | {"step_match":[{"id":"1", "args":[]}]} |
    When I run cucumber --dry-run -f progress features
    And it should pass with
      """
      -

      1 scenario (1 skipped)
      1 step (1 skipped)

      """


  #
  # invoke
  #
  # Assuming a step_match was returned for a given step name, when it's time to invoke that
  # step definition, Cucumber will send an invoke message.
  # The message contains the ID of the step definition, as returned by the wire end from the
  # step_matches call, along with the arguments that were parsed from the step name during the
  # same step_matches call.
  # The wire end will reply with either a step_failed or a success message.

  Scenario: Invoke a step definition which passes
    Given there is a wire server running on port 98989 which understands the following protocol:
      | request                                          | response                               |
      | {"step_matches":{"step_name":"we're all wired"}} | {"step_match":[{"id":"1", "args":[]}]} |
      | {"invoke":{"id":"1","args":[]}}                  | {"success":null}                       |
    When I run cucumber -f progress features
    And it should pass with
      """
      .

      1 scenario (1 passed)
      1 step (1 passed)

      """

  Scenario: Invoke a step definition which fails
    Given there is a wire server running on port 98989 which understands the following protocol:
      | request                                          | response                                         |
      | {"step_matches":{"step_name":"we're all wired"}} | {"step_match":[{"id":"1", "args":[]}]}           |
      | {"invoke":{"id":"1","args":[]}}                  | {"step_failed":{"message":"The wires are down"}} |
    When I run cucumber -f progress features
    And it should fail with
      """
      F

      (::) failed steps (::)

      The wires are down (Cucumber::WireSupport::WireException)
      features/wired.feature:2:in `Given we're all wired'

      Failing Scenarios:
      cucumber features/wired.feature:1 # Scenario: Wired

      1 scenario (1 failed)
      1 step (1 failed)

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