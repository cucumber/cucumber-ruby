Feature: Cucumber command line
  In order to write better software
  Developers should be able to execute requirements as tests

  Scenario: Run scenario outline steps only
    When I run cucumber -q features/outline_sample.feature:7
    Then it should fail with
      """
      Feature: Outline Sample

        Scenario Outline: Test state
          Given <state> without a table
          Given <other_state> without a table

        Examples: Rainbow colours
          | state   | other_state |
          | missing | passing     |
          | passing | passing     |
          | failing | passing     |
          FAIL (RuntimeError)
          ./features/step_definitions/sample_steps.rb:2:in `flunker'
          ./features/step_definitions/sample_steps.rb:16:in `/^failing without a table$/'
          features/outline_sample.feature:6:in `Given <state> without a table'

        Examples: Only passing
          | state   | other_state |
          | passing | passing     |

      4 scenarios
      1 failed step
      2 skipped steps
      1 undefined step
      4 passed steps

      """

  Scenario: Run single failing scenario outline table row
    When I run cucumber features/outline_sample.feature:12
    Then it should fail with
      """
      Feature: Outline Sample

        Scenario Outline: Test state          # features/outline_sample.feature:5
          Given <state> without a table       # features/step_definitions/sample_steps.rb:12
          Given <other_state> without a table # features/step_definitions/sample_steps.rb:12

        Examples: Rainbow colours
          | state   | other_state |
          | failing | passing     |
          FAIL (RuntimeError)
          ./features/step_definitions/sample_steps.rb:2:in `flunker'
          ./features/step_definitions/sample_steps.rb:16:in `/^failing without a table$/'
          features/outline_sample.feature:6:in `Given <state> without a table'

      1 scenario
      1 failed step
      1 skipped step

      """

  Scenario: Run all with progress formatter
    When I run cucumber -q --format progress features/outline_sample.feature
    Then it should fail with
      """
      --U-..F-..

      (::) failed steps (::)

      FAIL (RuntimeError)
      ./features/step_definitions/sample_steps.rb:2:in `flunker'
      ./features/step_definitions/sample_steps.rb:16:in `/^failing without a table$/'
      features/outline_sample.feature:6:in `Given <state> without a table'

      5 scenarios
      1 failed step
      2 skipped steps
      1 undefined step
      4 passed steps

      """

