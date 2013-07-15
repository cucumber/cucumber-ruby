Feature: Rerun formatter

  The rerun formatter writes an output that's perfect for
  passing to Cucumber when you want to rerun only the 
  scenarios that have failed.

  You can save off the rerun output to a file by using it like this:

  `cucumber -f rerun --out .cucumber.rerun`

  Now you can pass that file's content to Cucumber to tell it
  which scenarios to run:

  `cucumber \`cat .cucumber.rerun\``

  This is useful when debugging in a large suite of features.

  Background:
    Given a file named "features/step_definitions/steps.rb" with:
      """
      Given(/failing/) { fail }
      Given(/pending/) { pending }
      Given(/passing/) { }

      """

  Scenario: Regular scenarios
    Given a file named "features/mixed.feature" with:
      """
      Feature: Mixed

        Scenario:
          Given failing

        Scenario:
          Given missing

        Scenario:
          Given pending

        Scenario:
          Given passing

      """
    And a file named "features/all_good.feature" with:
      """
      Feature: All good

        Scenario:
          Given passing
      """

    When I run `cucumber -f rerun`
    Then it should fail with:
      """
      features/mixed.feature:3:6:9
      """

  Scenario: Scenario outlines
    For details see https://github.com/cucumber/cucumber/issues/57
    Given a file named "features/one_passing_one_failing.feature" with:
      """
      Feature: One passing example, one failing example

        Scenario Outline:
          Given a <status> step
        
        Examples:
          | status  |
          | passing |
          | failing |

      """
    When I run `cucumber -f rerun`
    Then it should fail with:
    """
    features/one_passing_one_failing.feature:9
    """

  Scenario: Scenario outlines with expand
  For details see https://github.com/cucumber/cucumber/issues/503
    Given a file named "features/one_passing_one_failing.feature" with:
    """
      Feature: One passing example, one failing example

        Scenario Outline:
          Given a <status> step

        Examples:
          | status  |
          | passing |
          | failing |

      """
    When I run `cucumber --expand -f rerun`
    Then it should fail with:
    """
    features/one_passing_one_failing.feature:9
    """

