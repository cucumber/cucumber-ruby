Feature: Multiline description names

  In order to accurately document feature elements, when writing your
  feature files it's possible to have your names run over more than one
  line, allowing you to be extra descriptive when you need to.

  Scenario: Multiline scenario
    Given a file named "features/multiline_name.feature" with:
    """
    Feature: multiline

      Background: I'm a multiline name
                  which goes on and on and on for three lines
                  yawn
        Given passing without a table

      Scenario: I'm a multiline name
                which goes on and on and on for three lines
                yawn
        Given passing without a table

      Scenario Outline: I'm a multiline name
                        which goes on and on and on for three lines
                        yawn
        Given <state> without a table
        Examples: Examples
          | state |
          |passing|

      Scenario Outline: name
        Given <state> without a table
        Examples: I'm a multiline name
                  which goes on and on and on for three lines
                  yawn
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

      Background: I'm a multiline name                        # features/multiline_name.feature:3
                  which goes on and on and on for three lines
                  yawn
        Given passing without a table                         # features/step_definitions/steps.rb:1

      Scenario: I'm a multiline name                        # features/multiline_name.feature:8
                which goes on and on and on for three lines
                yawn
        Given passing without a table                       # features/step_definitions/steps.rb:1

      Scenario Outline: I'm a multiline name                        # features/multiline_name.feature:13
                        which goes on and on and on for three lines
                        yawn
        Given <state> without a table                               # features/step_definitions/steps.rb:1

        Examples: Examples
          | state   |
          | passing |

      Scenario Outline: name          # features/multiline_name.feature:21
        Given <state> without a table # features/step_definitions/steps.rb:1

        Examples: I'm a multiline name
                  which goes on and on and on for three lines
                  yawn
          | state   |
          | passing |

    3 scenarios (3 passed)
    6 steps (6 passed)
    """
