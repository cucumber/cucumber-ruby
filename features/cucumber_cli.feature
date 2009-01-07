Feature: Run single scenario
  In order to speed up development
  Developers should be able to run just a single scenario
  
  Scenario: Run single scenario with missing step definition
    When I run cucumber -q features/sample.feature:3
    Then the output should be
      """
      Feature: Sample
        Scenario: Missing
          Given missing


      1 scenario
      1 step pending (1 with no step definition)
      
      """
      
  Scenario: Run single failing scenario
    When I run cucumber -q features/sample.feature:9
    Then the output should be
      """
      Feature: Sample
        Scenario: Failing
          Given failing
            FAIL (RuntimeError)
            ./features/step_definitions/sample_steps.rb:5:in `Given /^failing$/'
            features/sample.feature:10:in `Given failing'


      1 scenario
      1 step failed

      """
      
  Scenario: Require missing step definition from elsewhere
    When I run cucumber -q -r ../../features/step_definitions/extra_steps.rb features/sample.feature:3
    Then the output should be
      """
      Feature: Sample
        Scenario: Missing
          Given missing


      1 scenario
      1 step passed

      """

  Scenario: Run all with progress formatter
    When I run cucumber -q --format progress features/sample.feature
    Then the output should be
      """
      P.F

      Pending Scenarios:
      
      1)  Sample (Missing)
      
      
      Failed:
      
      1)
      FAIL
      ./features/step_definitions/sample_steps.rb:5:in `Given /^failing$/'
      features/sample.feature:10:in `Given failing'

      """
