@wire
Feature: Failing hooks

  When an hook fails (when invoked via begin_scenario or end_scenario), it can return
  details of the exception in the reply to invoke. This causes a 
  `Cucumber::WireSupport::WireException` to be raised.

  Valid arguments are:

  * `message` (mandatory)
  * `exception`
  * `backtrace`

  See the specs for `Cucumber::WireSupport::WireException` for more details

  Background:
    Given a file named "features/wired.feature" with:
      """
      Feature: High strung
        Scenario: Wired
          Given we're all wired

      """
    And a file named "features/step_definitions/some_remote_place.wire" with:
      """
      host: localhost
      port: 54321

      """

  Scenario: Exception in a before hook
    Given there is a wire server running on port 54321 which understands the following protocol:
      | request                                              | response                                                                            |
      | ["step_matches",{"name_to_match":"we're all wired"}] | ["success",[{"id":"1", "args":[]}]]                                                 |
      | ["begin_scenario"]                                   | ["fail",{"message":"The wires are down", "exception":"Some.Foreign.ExceptionType"}] |
    When I run `cucumber -f pretty`
    Then it should fail with exactly:
      """
      Feature: High strung

        Scenario: Wired         # features/wired.feature:2
        The wires are down (Some.Foreign.ExceptionType from localhost:54321)
        features/wired.feature:3:in `Before'
          Given we're all wired # features/wired.feature:3

      Failing Scenarios:
      cucumber features/wired.feature:3 # Scenario: Wired

      1 scenario (1 failed)
      1 step (1 skipped)
      """

