Feature: Test Step is available in AfterStep Block
  In order to inspect a Test Step after it has executed
  As a developer
  I want Test Step objects available in AfterStep blocks

  Scenario: Access Test Step object in AfterStep Block
    Given the standard step definitions
    And a file named "features/support/env.rb" with:
      """
      AfterStep do |test_step, result|
        expect(test_step).to be_a(Cucumber::Core::Test::Step)
      end
      """
    And a file named "features/sample.feature" with:
      """
      Feature: Sample

        Scenario: Success
          Given this step passes
      """
    When I run `cucumber features`
    Then it should pass with:
      """
      Feature: Sample

        Scenario: Success        # features/sample.feature:3
          Given this step passes # features/step_definitions/steps.rb:1

      1 scenario (1 passed)
      1 step (1 passed)

      """