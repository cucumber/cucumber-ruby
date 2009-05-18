Feature: --expand option
  In order to make it easier to writhe certain editor plugins
  and also for some people to understand scenarios, Cucumber
  should expand examples in outlines.

  Background:
    Given a standard Cucumber project directory structure
    And a file named "features/expand_me.feature" with:
      """
      Feature: submit guess
        Scenario Outline: submit guess
          Given the secret code is <code>
          When I guess <guess>
          Then the mark should be <mark>

        Examples: all colors correct
          | code    | guess   | mark |
          | r g y c | r g y c | bbbb |
          | r g y c | r g c y | bbww |
      """

  Scenario: Expand the outline
    When I run cucumber -i -q --expand features/expand_me.feature
    Then the output should contain
      """
      Feature: submit guess

        Scenario Outline: submit guess
          Given the secret code is <code>
          When I guess <guess>
          Then the mark should be <mark>

          Examples: all colors correct
        Scenario Outline: submit guess
          Given the secret code is r g y c
          When I guess r g y c
          Then the mark should be bbbb
        Scenario Outline: submit guess
          Given the secret code is r g y c
          When I guess r g c y
          Then the mark should be bbww
      """