Feature: Retry failing tests

  Retry gives you a way to get through flaky tests usually pass after a few runs.
  This gives a development team a way forward other than disabling a valuable test.
  
  - Specify max retry count in option
  - Output information to the screen
  - Output retry information in test report
  
  Questions:
  use a tag for flaky tests?  Global option to retry any test that fails?
  
  Background:
    Given a flaky step definition
  
  Scenario: run a flaky test
    Given a file named "features/fail.feature" with:
      """
      Feature: Fails

        Scenario: flaky test
          Given a flaky step

      """
    When I run `cucumber features -q`
    Then it should fail with:
      """
      Feature: Fails
      
        Scenario: flaky test
          Given a flaky step
             (RuntimeError)
            ./features/step_definitions/steps.rb:4:in `flaky_pass'
            ./features/step_definitions/steps.rb:1:in `/^a flaky step$/'
            features/fail.feature:4:in `Given a flaky step'
      
      Failing Scenarios:
      cucumber features/fail.feature:3
      
      1 scenario (1 failed)
      1 step (1 failed)

      """
  @wip      
  Scenario: rerun a flaky test
    Given a file named "features/fail.feature" with:
      """
      Feature: Fails

        Scenario: flaky test
          Given a flaky step

      """
    When I run `cucumber features --rerun_flakes=1 -q`
    Then it should pass with:
      """
      Feature: Fails
      
        Scenario: flaky test
          Given a flaky step
             (RuntimeError)
            ./features/step_definitions/steps.rb:4:in `flaky_pass'
            ./features/step_definitions/steps.rb:1:in `/^a flaky step$/'
            features/fail.feature:4:in `Given a flaky step'
      
      Failing Scenarios:
      cucumber features/fail.feature:3
      
      1 scenario (1 passed, 1 flake)
      1 step (1 passed)

      """