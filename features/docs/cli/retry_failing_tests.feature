Feature: Retry failing tests

  Retry gives you a way to get through flaky tests that usually pass after a few runs.
  This gives a development team a way forward other than disabling a valuable test.
  
  - Specify max retry count in option
  - Output information to the screen
  - Output retry information in test report
  
  Questions:
  use a tag for flaky tests?  Global option to retry any test that fails?
  
  Background:
    Given a file named "features/step_definitions/flaky_steps.rb" with:
      """
      Given(/^a flaky step$/) do
        $answer ||= 0
        $answer += 1
        expect(@answer).to eq 2
      end
      """
  
  Scenario: Run a flaky test
    Given a file named "features/flaky.feature" with:
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

            expected: 1
                 got: 0

            (compared using ==)
             (RSpec::Expectations::ExpectationNotMetError)
            ./features/step_definitions/flaky_steps.rb:3:in `/^a flaky step$/'
            features/flaky.feature:4:in `Given a flaky step'

      Failing Scenarios:
      cucumber features/fail.feature:3

      1 scenario (1 failed)
      1 step (1 failed)
      """

  Scenario: Retry a flaky test
    Given a file named "features/flaky.feature" with:
      """
      Feature: Fails

        Scenario: flaky test
          Given a flaky step

      """
    When I run `cucumber features --retry=1 -q`
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

  Scenario: One failure, one flake
    Given a file named "features/step_definitions/failing_steps.rb" with:
      """
      Given(/^a failing step$/) do
        expect(true).not_to be true
      end
      """
    And a file named "features/flaky.feature" with:
      """
      Feature: Fails

        Scenario: Flaky
          Given a flaky step

        Scenario: Failing
          Given a failing step
      """
    When I run `cucumber features --retry=1 -q`
    Then it should fail with:
      """
      Feature: Fails

        Scenario: Flaky
          Given a flaky step
            (RuntimeError)
            ./features/step_definitions/steps.rb:4 in `flaky_pass'
            ./features/step_definitions/steps.rb:1 in `/^a flaky step$/'
            features/fail.feature:4:in `Given a flaky step`

        Scenario: Failing
          Given a failing step
            (RuntimeError)
            ./features/step_definitions/failing_steps.rb:4 in `expect'
            ./features/step_definitions/failing_steps.rb:1 in `/^a failing step$/'
            features/fail.feature:7:in `Given a failing step'

        2 scenarios (1 passed, 1 failed, 1 flake)
        2 steps (1 passed)
      """