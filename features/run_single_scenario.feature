Feature: Run single scenario
  In order to speed up development
  Developers should be able to run just a single scenario
  
  Scenario: Missing
    When I run cucumber -q features/sample.feature:3
    Then the output should be
      """
      Feature: Sample
        Scenario: Missing
          Given missing


      1 scenario
      1 step pending (1 with no step definition)
      
      """
      
  Scenario: Failing
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