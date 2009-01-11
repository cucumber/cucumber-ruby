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
    When I run cucumber -q features/outline_sample.feature:9
    Then it should fail with
      """
      Feature: Outline Sample
        Scenario Outline: Test state
          Given <state> without a table

          |state  |
          |failing|

            FAIL (RuntimeError)
            ./features/step_definitions/sample_steps.rb:12:in ` /^failing without a table$/'
            features/outline_sample.feature:9:in `/^failing without a table$/'

      2 scenarios
      1 step failed

      """

  Scenario: Run all with progress formatter
    When I run cucumber -q --format progress features/outline_sample.feature
    Then it should fail with
      """
      P.F

      Pending Scenarios:

      1)  Outline Sample (Test state)


      Failed:

      1)
      FAIL
      ./features/step_definitions/sample_steps.rb:12:in ` /^failing without a table$/'
      features/outline_sample.feature:9:in `/^failing without a table$/'

      """
