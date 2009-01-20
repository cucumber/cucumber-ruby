Feature: Cucumber command line
  In order to write better software
  Developers should be able to execute requirements as tests
  
  Scenario: Run scenario outline steps only
    When I run cucumber -q features/outline_sample.feature:3
    Then it should pass with
      """
      Feature: Outline Sample
        Scenario Outline: Test state
          Given <state> without a table

          |state  |

      1 scenario
    
      """
  
  Scenario: Run single scenario outline table row with missing step definition
    When I run cucumber -q features/outline_sample.feature:7
    Then it should pass with
      """
      Feature: Outline Sample
        Scenario Outline: Test state
          Given <state> without a table

          |state  |
          |missing|

      2 scenarios
      1 step pending (1 with no step definition)
      
      """

  Scenario: Run single failing scenario outline table row
    When I run cucumber features/outline_sample.feature:5
    Then it should fail with
      """
      Feature: Outline Sample

        Scenario Outline: Test state          # features/outline_sample.feature:5
          Given <state> without a table
          Given <other_state> without a table

        Examples: 
          | state   | other_state |
          | missing | passing     |
          | passing | passing     |
          | failing | passing     |
            FAIL (RuntimeError)
            ./features/step_definitions/sample_steps.rb:2:in `flunker'
            ./features/step_definitions/sample_steps.rb:16:in `/^failing without a table$/'
            features/outline_sample.feature:12:in `Given failing without a table'

      3 scenarios
      1 step failed
      2 steps skipped
      1 step undefined
      2 steps passed

      """

  Scenario: Run all with progress formatter
    When I run cucumber -q --format progress features/outline_sample.feature
    Then it should fail with
      """
      UUS..FS

      (::) undefined (::)

      features/outline_sample.feature:3:in `Scenario: I have no steps'

      features/outline_sample.feature:10:in `Given missing without a table'

      (::) failed (::)

      FAIL (RuntimeError)
      ./features/step_definitions/sample_steps.rb:2:in `flunker'
      ./features/step_definitions/sample_steps.rb:16:in `/^failing without a table$/'
      features/outline_sample.feature:12:in `Given failing without a table'

      4 scenarios
      1 step failed
      2 steps skipped
      1 step undefined
      2 steps passed

      """
