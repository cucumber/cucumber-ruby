Feature: Multiline description names
  In order to accurately document feature elements
  As a cucumberist
  I want to have multiline names

  Scenario: multiline scenario
    When I run cucumber features/multiline_name.feature --no-snippets
    Then it should pass with
    """
    Feature: multiline

      Scenario: I'm a multiline name                 # features/multiline_name.feature:3
        which goes on and on and on for three lines
        yawn
        Given passing without a table                # features/step_definitions/sample_steps.rb:12

    1 scenario
    1 passed step

    """
