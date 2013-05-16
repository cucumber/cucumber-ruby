Feature: Using descriptions to give features context

  When writing your feature files its very helpful to use description
  text at the beginning of the feature file, to write a preamble to the
  feature describing clearly exactly what the feature does.

  You can also write descriptions attached to individual scenarios - see
  the examples below for how this can be used.

  It's possible to have your descriptions run over more than one line
  and you can have blank lines too, as long as you don't mention a
  word such as Given, When, Then, Background:, Scenario: or similar,
  otherwise Gherkin will start to pay attention.

  Scenario: Multiline scenario
    Given a file named "features/multiline_name.feature" with:
    """
    Feature: multiline

      We can put a useful description here of the feature.

      Background:
        We can also put descriptions of what the background is doing...
        Given passing without a table

      Scenario: I'm a multiline name
        ...and also put descriptions in front of the scenarios.
        Given passing without a table

      Scenario Outline: I'm a multiline name
        Scenario outlines can also have descriptions...
        Given <state> without a table
        Examples: Examples
          | state |
          |passing|

      Scenario Outline: name
        Given <state> without a table
        Examples: I'm a multiline name
          ...as can the specific examples for an outline.
          | state |
          |passing|
    """
    And a file named "features/step_definitions/steps.rb" with:
    """
    Given(/^passing without a table$/) do end
    """
    When I run `cucumber features/multiline_name.feature --no-snippets`
    Then the stderr should not contain anything
    Then it should pass with:
    """
    Feature: multiline
      
      We can put a useful description here of the feature.

      Background:                                                       # features/multiline_name.feature:5
        We can also put descriptions of what the background is doing...
        Given passing without a table                                   # features/step_definitions/steps.rb:1

      Scenario: I'm a multiline name                            # features/multiline_name.feature:9
        ...and also put descriptions in front of the scenarios.
        Given passing without a table                           # features/step_definitions/steps.rb:1

      Scenario Outline: I'm a multiline name            # features/multiline_name.feature:13
        Scenario outlines can also have descriptions...
        Given <state> without a table                   # features/step_definitions/steps.rb:1

        Examples: Examples
          | state   |
          | passing |

      Scenario Outline: name          # features/multiline_name.feature:20
        Given <state> without a table # features/step_definitions/steps.rb:1

        Examples: I'm a multiline name
          ...as can the specific examples for an outline.
          | state   |
          | passing |

    3 scenarios (3 passed)
    6 steps (6 passed)
    """
