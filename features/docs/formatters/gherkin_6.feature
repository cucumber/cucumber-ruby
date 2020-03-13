Feature: Gherkin 6 and old formatters

  Formatters built-in `cucumber-ruby` can produce valid output
  with features written with Gherkin 6+ syntax.

  Background:
    Given the standard step definitions
    And a file named "features/my_feature.feature" with:
    """
      Feature: Using Gherkin 6+ syntax

        Example: another name for scenario
          Given this step passes

        Scenario: with examples
          Given this step <status>

          Examples:
            | status |
            | passes |
            | fails  |

        Rule: First Rule
          Scenario:
            Given this step is undefined
    """

  Scenario: summary formatter
    When I run `cucumber --format summary`
    Then it should fail with:
    """
    Using Gherkin 6+ syntax
      another name for scenario ✓
      with examples ✓
      with examples ✗
       ?
    """

  Scenario: progress formatter
    When I run `cucumber --format progress`
    Then it should fail with:
      """
      ..FU

      (::) failed steps (::)

       (RuntimeError)
      ./features/step_definitions/steps.rb:4:in `/^this step fails$/'
      features/my_feature.feature:12:7:in `this step fails'
      """

  Scenario: pretty formatter
    The rule is skipped in the output

    When I run `cucumber --format pretty`
    Then it should fail with:
      """
      Feature: Using Gherkin 6+ syntax

        Example: another name for scenario # features/my_feature.feature:3
          Given this step passes           # features/step_definitions/steps.rb:1

        Scenario: with examples    # features/my_feature.feature:6
          Given this step <status> # features/my_feature.feature:7

          Examples: 
            | status |
            | passes |
            | fails  |
             (RuntimeError)
            ./features/step_definitions/steps.rb:4:in `/^this step fails$/'
            features/my_feature.feature:12:7:in `this step fails'

        Scenario:                      # features/my_feature.feature:15
          Given this step is undefined # features/my_feature.feature:16
      """

  Scenario: usage formatter
    When I run `cucumber --format usage --dry-run`
    Then it should pass with:
    """
    /^this step fails$/             # features/step_definitions/steps.rb:4
      Given this step fails         # features/my_feature.feature:12:7
    /^this step is a table step$/   # features/step_definitions/steps.rb:5
      NOT MATCHED BY ANY STEPS
    /^this step is pending$/        # features/step_definitions/steps.rb:3
      NOT MATCHED BY ANY STEPS
    /^this step passes$/            # features/step_definitions/steps.rb:1
      Given this step passes        # features/my_feature.feature:4
      Given this step passes        # features/my_feature.feature:11:7
    /^this step raises an error$/   # features/step_definitions/steps.rb:2
      NOT MATCHED BY ANY STEPS

    4 scenarios (3 skipped, 1 undefined)
    4 steps (3 skipped, 1 undefined)
    """